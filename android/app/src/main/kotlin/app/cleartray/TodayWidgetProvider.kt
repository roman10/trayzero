package app.cleartray

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import androidx.core.os.BundleCompat
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Renders today's focused items and overlays completions queued by the widget. */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        render(context, appWidgetManager, appWidgetIds, widgetData)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        val snapshot = readSnapshot(context, HomeWidgetPlugin.getData(context))
        appWidgetManager.updateAppWidget(appWidgetId, resize(context, snapshot, newOptions))
    }

    companion object {
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
            val snapshot = readSnapshot(context, data)
            widgetIds.forEach { widgetId ->
                val options = manager.getAppWidgetOptions(widgetId)
                manager.updateAppWidget(widgetId, resize(context, snapshot, options))
            }
        }

        private fun readSnapshot(context: Context, data: SharedPreferences): Snapshot {
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val snapshot = data.getString(ExternalQueue.SNAPSHOT_KEY, null)
                ?.let { runCatching { JSONObject(it) }.getOrNull() }
                ?.takeIf { it.optString("day") == today }
                ?: return Snapshot(emptyList(), 0, 0)
            val pending = ExternalQueue.pendingCompletionIds(context)
            val items = snapshot.optJSONArray("items")
            val rows = (0 until (items?.length() ?: 0)).mapNotNull { index ->
                val row = items?.optJSONObject(index) ?: return@mapNotNull null
                val id = row.optString("id").takeIf { it.isNotEmpty() } ?: return@mapNotNull null
                Row(id, row.optString("title"), id in pending)
            }
            return Snapshot(rows, snapshot.optInt("more"), snapshot.optInt("done"))
        }

        private fun resize(context: Context, snapshot: Snapshot, options: Bundle): RemoteViews {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val sizes = BundleCompat.getParcelableArrayList(
                    options, AppWidgetManager.OPTION_APPWIDGET_SIZES, SizeF::class.java
                )
                if (!sizes.isNullOrEmpty()) {
                    return RemoteViews(sizes.associateWith { viewsAtHeight(context, snapshot, it.height) })
                }
            }
            // Older hosts report a range. The shorter height is for landscape,
            // and the taller height is for portrait.
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
            val maxHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
            val landscape = viewsAtHeight(context, snapshot, minHeight.toFloat())
            return if (maxHeight > minHeight) {
                RemoteViews(landscape, viewsAtHeight(context, snapshot, maxHeight.toFloat()))
            } else {
                landscape
            }
        }

        internal fun viewsAtHeight(context: Context, snapshot: Snapshot, height: Float): RemoteViews {
            val res = context.resources
            val heightPx = if (height > 0) {
                (height * res.displayMetrics.density).toInt()
            } else {
                res.getDimensionPixelSize(R.dimen.today_widget_min_height)
            }
            val padding = res.getDimensionPixelSize(R.dimen.today_widget_vertical_padding)
            val header = res.getDimensionPixelSize(R.dimen.today_widget_header_height)
            val row = res.getDimensionPixelSize(R.dimen.today_widget_row_height)
            val overflow = res.getDimensionPixelSize(R.dimen.today_widget_overflow_height)
            val remaining = heightPx - 2 * padding - header
            val total = snapshot.rows.size + snapshot.more
            val capacity = remaining / row
            val visible = if (total > capacity) (remaining - overflow) / row else capacity
            val displayRows = snapshot.rows.take(visible.coerceAtLeast(0))
            val pending = snapshot.rows.count { it.pending }
            val status = when {
                pending > 0 -> context.getString(R.string.today_widget_pending, pending)
                snapshot.done > 0 -> context.getString(R.string.today_widget_done, snapshot.done)
                else -> ""
            }
            val more = total - displayRows.size
            val openToday = LaunchLinks.pendingIntent(context, "cleartray://today")

            return RemoteViews(context.packageName, R.layout.trayzero_today_widget).apply {
                setOnClickPendingIntent(R.id.today_header, openToday)
                setTextViewText(R.id.today_status, status)

                removeAllViews(R.id.today_rows)
                for (item in displayRows) {
                    addView(R.id.today_rows, rowViews(context, item))
                }

                setViewVisibility(R.id.today_more, if (more > 0) View.VISIBLE else View.GONE)
                setTextViewText(R.id.today_more, context.getString(R.string.today_widget_more, more))
                setOnClickPendingIntent(R.id.today_more, openToday)

                setViewVisibility(R.id.today_empty, if (total == 0) View.VISIBLE else View.GONE)
                setTextViewText(
                    R.id.today_empty_title,
                    context.getString(
                        if (snapshot.done > 0) R.string.today_widget_all_done else R.string.today_widget_empty
                    )
                )
                setOnClickPendingIntent(
                    R.id.today_plan_button, LaunchLinks.pendingIntent(context, "cleartray://plan")
                )
            }
        }

        private fun rowViews(context: Context, row: Row): RemoteViews =
            RemoteViews(context.packageName, R.layout.trayzero_today_widget_row).apply {
                setTextViewText(R.id.today_row_title, row.title)
                setOnClickPendingIntent(
                    R.id.today_row_title,
                    LaunchLinks.pendingIntent(context, "cleartray://item?id=${Uri.encode(row.id)}")
                )
                setContentDescription(
                    R.id.today_row_check,
                    context.getString(
                        if (row.pending) R.string.today_widget_completion_pending
                        else R.string.today_widget_complete,
                        row.title
                    )
                )
                if (row.pending) {
                    setTextColor(R.id.today_row_title, context.getColor(R.color.today_widget_text_muted))
                    setImageViewResource(R.id.today_row_check, R.drawable.ic_widget_check_done)
                } else {
                    setOnClickPendingIntent(R.id.today_row_check, completeIntent(context, row.id))
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

    internal data class Row(val id: String, val title: String, val pending: Boolean)
    internal data class Snapshot(val rows: List<Row>, val more: Int, val done: Int)
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
