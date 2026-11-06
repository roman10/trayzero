package app.cleartray

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Today widget (ADR 0009): focused Items with a complete checkbox. Renders the
 * app's `today_snapshot` with queued completions applied optimistically. A
 * snapshot from an earlier local day renders empty: its Items are carry-over.
 */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        render(context, appWidgetManager, appWidgetIds, widgetData)
    }

    companion object {
        private val rows = listOf(
            Triple(R.id.today_row_0, R.id.today_check_0, R.id.today_title_0),
            Triple(R.id.today_row_1, R.id.today_check_1, R.id.today_title_1),
            Triple(R.id.today_row_2, R.id.today_check_2, R.id.today_title_2),
            Triple(R.id.today_row_3, R.id.today_check_3, R.id.today_title_3),
            Triple(R.id.today_row_4, R.id.today_check_4, R.id.today_title_4),
        )

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, TodayWidgetProvider::class.java))
            if (ids.isNotEmpty()) render(context, manager, ids, HomeWidgetPlugin.getData(context))
        }

        private fun render(
            context: Context,
            manager: AppWidgetManager,
            widgetIds: IntArray,
            data: SharedPreferences
        ) {
            val snapshot = data.getString(ExternalQueue.SNAPSHOT_KEY, null)
                ?.let { runCatching { JSONObject(it) }.getOrNull() }
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val fresh = snapshot != null && snapshot.optString("day") == today
            val items = mutableListOf<Pair<String, String>>()
            if (fresh) {
                val array = snapshot!!.optJSONArray("items")
                for (i in 0 until (array?.length() ?: 0)) {
                    val row = array!!.optJSONObject(i) ?: continue
                    val id = row.optString("id")
                    if (id.isNotEmpty()) items += id to row.optString("title")
                }
            }
            val pending = ExternalQueue.pendingCompletionIds(context)
            val done = (if (fresh) snapshot!!.optInt("done") else 0) +
                items.count { it.first in pending }
            val more = (if (fresh) snapshot!!.optInt("more") else 0) +
                maxOf(0, items.size - rows.size)

            widgetIds.forEach { widgetId ->
                val views = RemoteViews(context.packageName, R.layout.trayzero_today_widget)
                views.setOnClickPendingIntent(
                    R.id.today_header,
                    LaunchLinks.pendingIntent(context, "cleartray://today")
                )
                views.setTextViewText(
                    R.id.today_done,
                    if (done > 0) context.getString(R.string.today_widget_done, done) else ""
                )

                rows.forEachIndexed { index, (row, check, title) ->
                    val item = items.getOrNull(index)
                    if (item == null) {
                        views.setViewVisibility(row, View.GONE)
                        return@forEachIndexed
                    }
                    val (id, text) = item
                    val completed = id in pending
                    views.setViewVisibility(row, View.VISIBLE)
                    views.setTextViewText(title, text)
                    views.setTextColor(
                        title,
                        context.getColor(
                            if (completed) R.color.today_widget_text_muted else R.color.today_widget_text
                        )
                    )
                    views.setImageViewResource(
                        check,
                        if (completed) R.drawable.ic_widget_check_done else R.drawable.ic_widget_check
                    )
                    views.setContentDescription(
                        check,
                        context.getString(R.string.today_widget_complete, text)
                    )
                    views.setOnClickPendingIntent(check, completeIntent(context, id))
                    views.setOnClickPendingIntent(
                        title,
                        LaunchLinks.pendingIntent(context, "cleartray://item?id=${Uri.encode(id)}")
                    )
                }

                views.setViewVisibility(R.id.today_more, if (more > 0 && items.isNotEmpty()) View.VISIBLE else View.GONE)
                views.setTextViewText(R.id.today_more, context.getString(R.string.today_widget_more, more))
                views.setOnClickPendingIntent(
                    R.id.today_more,
                    LaunchLinks.pendingIntent(context, "cleartray://today")
                )

                views.setViewVisibility(R.id.today_empty, if (items.isEmpty()) View.VISIBLE else View.GONE)
                views.setTextViewText(
                    R.id.today_empty_title,
                    context.getString(
                        if (done > 0) R.string.today_widget_all_done else R.string.today_widget_empty
                    )
                )
                views.setOnClickPendingIntent(
                    R.id.today_plan_button,
                    LaunchLinks.pendingIntent(context, "cleartray://plan")
                )
                manager.updateAppWidget(widgetId, views)
            }
        }

        private fun completeIntent(context: Context, id: String): PendingIntent {
            val intent = Intent(context, TodayWidgetActionReceiver::class.java)
                .setAction(TodayWidgetActionReceiver.ACTION_COMPLETE)
                // Distinct data keeps one PendingIntent per Item.
                .setData(Uri.parse("cleartray://complete?id=${Uri.encode(id)}"))
                .putExtra(TodayWidgetActionReceiver.EXTRA_ID, id)
            return PendingIntent.getBroadcast(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}

/**
 * Not exported: only this app's widget PendingIntents can complete Items.
 * Queues the tap for the app, re-renders optimistically, and pokes a live app.
 */
class TodayWidgetActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_COMPLETE = "app.cleartray.action.COMPLETE_TODAY_ITEM"
        const val EXTRA_ID = "id"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_COMPLETE) return
        val id = intent.getStringExtra(EXTRA_ID)?.takeIf { it.isNotEmpty() } ?: return
        if (id in ExternalQueue.pendingCompletionIds(context)) return
        ExternalQueue.appendCompletion(context, id, System.currentTimeMillis())
        TodayWidgetProvider.refreshAll(context)
        LaunchLinks.notifyQueueChanged()
    }
}
