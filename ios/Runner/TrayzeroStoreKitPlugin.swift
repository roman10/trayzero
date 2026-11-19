import Flutter
import StoreKit
import UIKit

public final class TrayzeroStoreKitPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  private var productIDs: Set<String> = []
  private var subscriptionIDs: Set<String> = []
  private var products: [String: Product] = [:]
  private var updates: Task<Void, Never>?
  private var foreground: Task<Void, Never>?
  private var recovery: Task<Void, Never>?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "app.cleartray/storekit", binaryMessenger: registrar.messenger())
    let plugin = TrayzeroStoreKitPlugin(channel: channel)
    registrar.addMethodCallDelegate(plugin, channel: channel)
    registrar.publish(plugin)
  }

  deinit {
    updates?.cancel()
    foreground?.cancel()
    recovery?.cancel()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    Task { @MainActor in
      do {
        switch call.method {
        case "configure":
          guard let arguments = call.arguments as? [String: [String]],
                let tips = arguments["tips"],
                let subscriptions = arguments["subscriptions"] else {
            result(FlutterError(code: "unavailable", message: nil, details: nil))
            return
          }
          configure(tips: tips, subscriptions: subscriptions)
          result(nil)
        case "products":
          result(try await loadProducts())
        case "currentStatus":
          result(await supporterStatus())
        case "purchase":
          guard let id = call.arguments as? String, productIDs.contains(id) else {
            result(FlutterError(code: "optionUnavailable", message: nil, details: nil))
            return
          }
          result(try await purchase(id))
        case "restore":
          try await AppStore.sync()
          result(await supporterStatus())
        default:
          result(FlutterMethodNotImplemented)
        }
      } catch {
        result(FlutterError(code: Self.errorCode(error), message: nil, details: nil))
      }
    }
  }

  @MainActor
  private func configure(tips: [String], subscriptions: [String]) {
    guard updates == nil else { return }
    productIDs = Set(tips + subscriptions)
    subscriptionIDs = Set(subscriptions)
    updates = Task { [weak self] in
      for await update in Transaction.updates {
        await self?.process(update)
      }
    }
    foreground = Task { [weak self] in
      for await _ in NotificationCenter.default.notifications(
        named: UIScene.didActivateNotification
      ) {
        await self?.publishStatus()
      }
    }
    // Recover verified purchases left unfinished by an interrupted or older build.
    recovery = Task { [weak self] in
      for await transaction in Transaction.unfinished {
        await self?.process(transaction)
      }
    }
  }

  @MainActor
  private func loadProducts() async throws -> [[String: Any]] {
    let catalog = try await Product.products(for: productIDs)
    products = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })
    return catalog.map { product in
      [
        "id": product.id,
        "title": product.displayName,
        "priceString": product.displayPrice,
        "rawPrice": NSDecimalNumber(decimal: product.price).doubleValue,
        "currencyCode": product.priceFormatStyle.currencyCode,
      ]
    }
  }

  @MainActor
  private func purchase(_ id: String) async throws -> Any {
    if products[id] == nil {
      _ = try await loadProducts()
    }
    guard let product = products[id] else {
      return FlutterError(code: "optionUnavailable", message: nil, details: nil)
    }
    switch try await product.purchase() {
    case .success(.verified(let transaction)):
      await transaction.finish()
      return await supporterStatus()
    case .success(.unverified):
      return FlutterError(code: "storeProblem", message: nil, details: nil)
    case .pending:
      return FlutterError(code: "pending", message: nil, details: nil)
    case .userCancelled:
      return FlutterError(code: "cancelled", message: nil, details: nil)
    @unknown default:
      return FlutterError(code: "storeProblem", message: nil, details: nil)
    }
  }

  @MainActor
  private func process(_ result: VerificationResult<Transaction>) async {
    guard case .verified(let transaction) = result,
          productIDs.contains(transaction.productID) else { return }
    await publishStatus()
    await transaction.finish()
  }

  @MainActor
  private func publishStatus() async {
    let status = await supporterStatus()
    channel.invokeMethod("statusChanged", arguments: status)
  }

  @MainActor
  private func supporterStatus() async -> [String: Any] {
    // StoreKit includes grace-period subscriptions and excludes revoked ones.
    // Checking expiration against the clock here would remove access in grace.
    var latest: Transaction?
    for await entitlement in Transaction.currentEntitlements {
      guard case .verified(let transaction) = entitlement,
            subscriptionIDs.contains(transaction.productID) else { continue }
      if latest.map({ $0.purchaseDate < transaction.purchaseDate }) ?? true {
        latest = transaction
      }
    }
    guard let latest else { return [:] }
    var status: [String: Any] = ["productId": latest.productID]
    if let expirationDate = latest.expirationDate {
      status["expiresAtMs"] = Int64(expirationDate.timeIntervalSince1970 * 1000)
    }
    return status
  }

  private static func errorCode(_ error: Error) -> String {
    switch error {
    case StoreKitError.userCancelled:
      return "cancelled"
    case StoreKitError.networkError, URLError.notConnectedToInternet, URLError.timedOut:
      return "network"
    case StoreKitError.notAvailableInStorefront, Product.PurchaseError.productUnavailable:
      return "optionUnavailable"
    case Product.PurchaseError.purchaseNotAllowed:
      return "notAllowed"
    default:
      return "storeProblem"
    }
  }
}
