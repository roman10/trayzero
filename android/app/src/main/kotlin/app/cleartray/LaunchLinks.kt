package app.cleartray

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

/**
 * System entry points (ADR 0009). Every tile, shortcut, and widget launch is a
 * `cleartray://` link sent with home_widget's launch action, so it reaches Dart
 * through the same cold/warm-start path as the Inbox widget.
 */
object LaunchLinks {
    const val CHANNEL = "app.cleartray/launch_link"

    fun intent(context: Context, link: String): Intent =
        Intent(context, MainActivity::class.java)
            .setAction(HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION)
            .setData(Uri.parse(link))

    fun pendingIntent(context: Context, link: String): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(link))

    /** Set while a Flutter engine is attached; lets native code signal queued work. */
    @Volatile
    var channel: MethodChannel? = null

    /** Ask a live app to drain the queue now instead of on its next resume. */
    fun notifyQueueChanged() {
        Handler(Looper.getMainLooper()).post {
            channel?.invokeMethod("queueChanged", null)
        }
    }
}

/**
 * The widget receiver and Flutter's method channel both run in this process.
 * Serialize the read/modify/write operations so an acknowledgment cannot
 * overwrite a concurrently queued tap.
 */
object ExternalQueue {
    const val SNAPSHOT_KEY = "today_snapshot"
    const val COMPLETIONS_KEY = "today_completions"
    private const val RECEIPT = "receipt"

    @Synchronized
    fun appendCompletion(context: Context, id: String, atMillis: Long) {
        val prefs = HomeWidgetPlugin.getData(context)
        val queue = readEntries(prefs)
        if (queue.any { it.optString("id") == id }) return
        queue.add(JSONObject()
            .put(RECEIPT, UUID.randomUUID().toString())
            .put("id", id)
            .put("at", atMillis))
        runCatching { persist(prefs, queue) }.onFailure {
            Log.e("TrayzeroWidget", "Could not persist the completion tap", it)
        }
    }

    @Synchronized
    fun pendingCompletionIds(context: Context): Set<String> =
        readEntries(HomeWidgetPlugin.getData(context))
            .map { it.optString("id") }
            .filter { it.isNotEmpty() }
            .toSet()

    @Synchronized
    fun readQueue(context: Context): String {
        val prefs = HomeWidgetPlugin.getData(context)
        val queue = readEntries(prefs)
        // Stable receipts also identify each distinct entry queued before upgrade.
        var migrated = false
        queue.forEach { entry ->
            if (entry.optString(RECEIPT, "").isEmpty()) {
                entry.put(RECEIPT, UUID.randomUUID().toString())
                migrated = true
            }
        }
        if (migrated) persist(prefs, queue)
        return JSONArray(queue).toString()
    }

    @Synchronized
    fun acknowledge(context: Context, receipts: Set<String>) {
        val prefs = HomeWidgetPlugin.getData(context)
        val queue = readEntries(prefs)
        val remaining = queue.filterNot { it.optString(RECEIPT, "") in receipts }
        if (remaining.size != queue.size) persist(prefs, remaining)
    }

    private fun readEntries(prefs: SharedPreferences): MutableList<JSONObject> {
        val queue = runCatching {
            JSONArray(prefs.getString(COMPLETIONS_KEY, "[]"))
        }.getOrElse { JSONArray() }
        return (0 until queue.length()).mapNotNull { queue.optJSONObject(it) }.toMutableList()
    }

    private fun persist(prefs: SharedPreferences, queue: List<JSONObject>) {
        check(prefs.edit().putString(COMPLETIONS_KEY, JSONArray(queue).toString()).commit()) {
            "Could not write external completion queue"
        }
    }
}
