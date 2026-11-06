package app.cleartray

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

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
 * Shared queues drained by Dart's `DrainExternalQueue`. Stored in home_widget's
 * preferences so `HomeWidget.getWidgetData` reads them unchanged.
 */
object ExternalQueue {
    const val SNAPSHOT_KEY = "today_snapshot"
    const val COMPLETIONS_KEY = "today_completions"

    @Synchronized
    fun appendCompletion(context: Context, id: String, atMillis: Long) {
        val prefs = HomeWidgetPlugin.getData(context)
        val queue = parseArray(prefs.getString(COMPLETIONS_KEY, null))
        queue.put(JSONObject().put("id", id).put("at", atMillis))
        prefs.edit().putString(COMPLETIONS_KEY, queue.toString()).commit()
    }

    fun pendingCompletionIds(context: Context): Set<String> {
        val queue = parseArray(HomeWidgetPlugin.getData(context).getString(COMPLETIONS_KEY, null))
        return (0 until queue.length()).mapNotNull { queue.optJSONObject(it)?.optString("id") }
            .filter { it.isNotEmpty() }
            .toSet()
    }

    private fun parseArray(raw: String?): JSONArray =
        raw?.let { runCatching { JSONArray(it) }.getOrNull() } ?: JSONArray()
}
