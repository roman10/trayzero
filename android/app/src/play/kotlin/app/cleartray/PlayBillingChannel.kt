package app.cleartray

import android.app.Activity
import android.util.Base64
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClient.BillingResponseCode
import com.android.billingclient.api.BillingClient.ProductType
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ConsumeParams
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import com.android.billingclient.api.acknowledgePurchase
import com.android.billingclient.api.consumePurchase
import com.android.billingclient.api.queryProductDetails
import com.android.billingclient.api.queryPurchasesAsync
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.security.GeneralSecurityException
import java.security.KeyFactory
import java.security.Signature
import java.security.spec.X509EncodedKeySpec
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withTimeout
import kotlin.coroutines.resume

internal class PlayBillingChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "app.cleartray/play_billing")
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    // Store callbacks and foreground/restore queries can overlap. A token is
    // checked and settled under the same lock regardless of how it arrived.
    private val operations = Mutex()
    private var inFlight: PurchaseFlow? = null

    private val client = BillingClient.newBuilder(activity.applicationContext)
        .setListener { result, purchases -> scope.launch { purchaseUpdated(result, purchases.orEmpty()) } }
        .enableAutoServiceReconnection()
        .enablePendingPurchases(
            PendingPurchasesParams.newBuilder().enableOneTimeProducts().enablePrepaidPlans().build()
        )
        .build()
    private var connectedOnce = false

    init {
        channel.setMethodCallHandler { call, reply ->
            if (call.method !in setOf("offerings", "refresh", "purchase")) {
                reply.notImplemented()
                return@setMethodCallHandler
            }
            scope.launch {
                try {
                    operations.withLock {
                        val result = withTimeout(STORE_TIMEOUT_MS) {
                            ensureConnection()
                            when (call.method) {
                                "offerings" -> products().map { it.wire }
                                "refresh" -> reconcile()
                                else -> launchPurchase(call.argument<String>("id"), reply)
                            }
                        }
                        // A successful launch returns through the purchase listener.
                        if (result != null) reply.success(result)
                    }
                } catch (failure: StoreFailure) {
                    reply.error(failure.reason, null, null)
                } catch (_: TimeoutCancellationException) {
                    reply.error("network", null, null)
                } catch (_: IllegalStateException) {
                    reply.error("storeProblem", null, null)
                } catch (_: IllegalArgumentException) {
                    reply.error("storeProblem", null, null)
                }
            }
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        inFlight?.reply?.error("unavailable", null, null)
        inFlight = null
        scope.cancel()
        client.endConnection()
    }

    private suspend fun ensureConnection() {
        // After setup succeeds, automatic reconnection handles service drops.
        if (connectedOnce) return
        val result = suspendCancellableCoroutine { continuation ->
            client.startConnection(object : BillingClientStateListener {
                override fun onBillingSetupFinished(result: BillingResult) {
                    if (continuation.isActive) continuation.resume(result)
                }

                override fun onBillingServiceDisconnected() = Unit
            })
        }
        checkResult(result)
        connectedOnce = true
    }

    private data class Product(val details: ProductDetails, val offerToken: String?, val wire: Map<String, Any>)
    private data class PurchaseFlow(val id: String, val reply: MethodChannel.Result)

    private suspend fun products(): List<Product> {
        val tips = queryProducts(ProductType.INAPP, TIP_PRODUCTS.keys)
        val subscriptions = try {
            queryProducts(ProductType.SUBS, PLANS.keys)
        } catch (failure: StoreFailure) {
            if (tips.isEmpty()) throw failure
            emptyList()
        }
        return tips + subscriptions
    }

    private suspend fun queryProducts(type: String, ids: Set<String>): List<Product> {
        val query = QueryProductDetailsParams.newBuilder().setProductList(ids.map { id ->
            QueryProductDetailsParams.Product.newBuilder().setProductId(id).setProductType(type).build()
        }).build()
        val result = client.queryProductDetails(query)
        checkResult(result.billingResult)
        return result.productDetailsList.orEmpty().mapNotNull(::product)
    }

    private fun product(details: ProductDetails): Product? {
        fun priced(token: String?, formatted: String, micros: Long, currency: String) =
            Product(details, token, mapOf(
                "id" to (TIP_PRODUCTS[details.productId] ?: details.productId),
                "title" to details.title,
                "priceString" to formatted,
                "rawPrice" to micros / 1_000_000.0,
                "currencyCode" to currency,
            ))

        if (details.productType == ProductType.INAPP) {
            val offers = details.oneTimePurchaseOfferDetailsList
            val offer = if (offers == null) {
                details.oneTimePurchaseOfferDetails
            } else {
                offers.firstOrNull { it.offerId == null && it.rentalDetails == null }
            } ?: return null
            return priced(offer.offerToken?.takeIf { it.isNotEmpty() }, offer.formattedPrice,
                offer.priceAmountMicros, offer.priceCurrencyCode)
        }
        val offer = details.subscriptionOfferDetails?.firstOrNull {
            it.basePlanId == PLANS[details.productId] && it.offerId == null
        } ?: return null
        val price = offer.pricingPhases.pricingPhaseList.singleOrNull() ?: return null
        return priced(offer.offerToken, price.formattedPrice, price.priceAmountMicros, price.priceCurrencyCode)
    }

    private suspend fun launchPurchase(id: String?, reply: MethodChannel.Result): Nothing? {
        if (inFlight != null) throw StoreFailure("storeProblem")
        val tipSku = TIP_PRODUCTS.entries.firstOrNull { it.value == id }?.key
        val sku = tipSku ?: id?.takeIf { it in PLANS } ?: throw StoreFailure("optionUnavailable")
        val type = if (tipSku != null) ProductType.INAPP else ProductType.SUBS
        // Resolve fresh details and the eligible base-plan token at launch.
        val product = queryProducts(type, setOf(sku)).singleOrNull { it.details.productId == sku }
            ?: throw StoreFailure("optionUnavailable")
        val item = BillingFlowParams.ProductDetailsParams.newBuilder()
            .setProductDetails(product.details)
        product.offerToken?.let(item::setOfferToken)
        val params = BillingFlowParams.newBuilder().setProductDetailsParamsList(listOf(item.build())).build()
        inFlight = PurchaseFlow(sku, reply)
        try {
            checkResult(client.launchBillingFlow(activity, params))
        } catch (failure: Exception) {
            inFlight = null
            throw failure
        }
        return null
    }

    private suspend fun purchaseUpdated(result: BillingResult, purchases: List<Purchase>) = operations.withLock {
        val flow = inFlight
        val matching = purchases.firstOrNull { flow?.id in it.products }
        // A successful update for another purchase does not resolve this sheet.
        val resolvesFlow = flow != null &&
            (matching != null || purchases.isEmpty() || result.responseCode != BillingResponseCode.OK)
        if (resolvesFlow) {
            try {
                withTimeout(STORE_TIMEOUT_MS) {
                    checkResult(result)
                    val purchase = matching ?: throw StoreFailure("storeProblem")
                    if (purchase.purchaseState == Purchase.PurchaseState.PENDING) throw StoreFailure("pending")
                    processPurchase(purchase, flow.id)
                }
                flow.reply.success(true)
            } catch (failure: StoreFailure) {
                flow.reply.error(failure.reason, null, null)
            } catch (_: TimeoutCancellationException) {
                flow.reply.error("network", null, null)
            } catch (_: IllegalArgumentException) {
                flow.reply.error("storeProblem", null, null)
            } catch (_: IllegalStateException) {
                flow.reply.error("storeProblem", null, null)
            } finally {
                inFlight = null
            }
        }
        // Dart re-queries ownership after a callback, including updates without
        // an open purchase sheet and ITEM_ALREADY_OWNED responses.
        channel.invokeMethod("purchasesChanged", null)
    }

    private suspend fun reconcile(): Map<String, Any?> {
        val subscriptions = owned(ProductType.SUBS)
        var active: String? = null
        var subscriptionError: StoreFailure? = null
        for (purchase in subscriptions) {
            val id = purchase.products.singleOrNull() ?: continue
            if (id !in PLANS || !isPurchased(purchase) || purchase.isSuspended) continue
            try {
                processPurchase(purchase, id)
                // Prefer yearly if both independent products are active.
                if (active == null || id == "supporter_yearly") active = id
            } catch (failure: StoreFailure) {
                // An unacknowledged purchase can be retried on the next query.
                // A concurrent revocation must never create an entitlement.
                if (failure.reason != "notOwned") subscriptionError = failure
            }
        }

        // Finish tips initiated on a previous build. The new tip SKUs are
        // consumed exclusively by the Play notification worker.
        try {
            for (purchase in owned(ProductType.INAPP)) {
                val id = purchase.products.singleOrNull() ?: continue
                if (id !in LEGACY_TIPS || !isPurchased(purchase)) continue
                try {
                    processPurchase(purchase, id)
                } catch (_: StoreFailure) {
                    // Leave unconsumed tips for the next reconciliation.
                }
            }
        } catch (_: StoreFailure) {
            // Subscription status remains authoritative.
        }
        return mapOf("activeProduct" to active, "failure" to subscriptionError?.reason)
    }

    private suspend fun owned(type: String): List<Purchase> {
        val query = QueryPurchasesParams.newBuilder().setProductType(type).includeSuspendedSubscriptions(false).build()
        val result = client.queryPurchasesAsync(query)
        checkResult(result.billingResult)
        return result.purchasesList
    }

    private fun isPurchased(purchase: Purchase): Boolean =
        purchase.purchaseState == Purchase.PurchaseState.PURCHASED &&
            purchase.packageName == activity.packageName &&
            purchase.purchaseToken.isNotBlank() &&
            PlayPurchaseSignature.verify(purchase.originalJson, purchase.signature)

    private suspend fun processPurchase(purchase: Purchase, id: String) {
        if (purchase.products != listOf(id) || !isPurchased(purchase) ||
            (id in PLANS && purchase.isSuspended)) {
            throw StoreFailure("storeProblem")
        }
        val token = purchase.purchaseToken
        if (id in LEGACY_TIPS) {
            checkResult(client.consumePurchase(ConsumeParams.newBuilder().setPurchaseToken(token).build()).billingResult)
        } else if (id in PLANS && !purchase.isAcknowledged) {
            checkResult(client.acknowledgePurchase(
                AcknowledgePurchaseParams.newBuilder().setPurchaseToken(token).build()
            ))
        }
        // Play's signed PURCHASED state is enough to thank a tipper.
        // The worker consumes new tip SKUs after receiving Play's notification.
    }

    private class StoreFailure(val reason: String) : Exception()

    private fun checkResult(result: BillingResult) {
        if (result.responseCode == BillingResponseCode.OK) return
        throw StoreFailure(when (result.responseCode) {
            BillingResponseCode.USER_CANCELED -> "cancelled"
            BillingResponseCode.ITEM_ALREADY_OWNED -> "alreadyOwned"
            BillingResponseCode.ITEM_NOT_OWNED -> "notOwned"
            BillingResponseCode.ITEM_UNAVAILABLE -> "optionUnavailable"
            BillingResponseCode.BILLING_UNAVAILABLE -> "notAllowed"
            BillingResponseCode.FEATURE_NOT_SUPPORTED -> "unavailable"
            BillingResponseCode.NETWORK_ERROR, BillingResponseCode.SERVICE_DISCONNECTED,
            BillingResponseCode.SERVICE_UNAVAILABLE -> "network"
            else -> "storeProblem"
        })
    }

    private companion object {
        const val STORE_TIMEOUT_MS = 20_000L
        val TIP_PRODUCTS = mapOf("tip_small_play" to "tip_small", "tip_large_play" to "tip_large")
        val LEGACY_TIPS = TIP_PRODUCTS.values.toSet()
        val PLANS = mapOf("supporter_monthly" to "monthly", "supporter_yearly" to "yearly")
    }
}

internal object PlayPurchaseSignature {
    // app.cleartray's public licensing key from Play Console > Monetisation setup.
    private const val PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxMkAhnvDvCrZjiCNf97SpRKSM+2Ok5i8jTXxNJ0W8OjHb1gE4k7iPJfhQYDj8oRiAf7dp8NpCngM5P575TxiPHKUnYsTGPeYlciEqvidPqnvRVYkNs3jIo0iDvA4dQRHMT06D81Gni4G95LRgAQCCbiKuyviwlE5ti2/k3yN1L9dTQ0z9hSweKllqRcuoZlGgcTGWbiPot+Kve7k3ozdcApWE6BLV1Emxek0YGqa7mtbli3cDsoiBsTAOAySoism6JUuHjdUOnbMWxuUy8PMAR/r6b7VY95KaLhghJK+eVFSju1YX+5dwTtLG/qtLyh5n3phVchl6lh3aI1KWT9P5wIDAQAB"

    private val key by lazy {
        KeyFactory.getInstance("RSA").generatePublic(X509EncodedKeySpec(Base64.decode(PUBLIC_KEY, Base64.DEFAULT)))
    }

    fun verify(json: String, signature: String): Boolean = try {
        // Play signs Purchase.originalJson with SHA1withRSA.
        Signature.getInstance("SHA1withRSA").run {
            initVerify(key)
            update(json.toByteArray(Charsets.UTF_8))
            verify(Base64.decode(signature, Base64.DEFAULT))
        }
    } catch (_: GeneralSecurityException) {
        false
    } catch (_: IllegalArgumentException) {
        false
    }
}
