package app.cleartray

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.appwidget.AppWidgetManager
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class CleartrayInboxWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.cleartray_inbox_widget).apply {
                val count = widgetData.getInt("inbox_count", 0)
                setTextViewText(R.id.widget_count, count.toString())
                setTextViewText(
                    R.id.widget_count_label,
                    if (count == 1) "item in Inbox" else "items in Inbox"
                )

                val captureIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("cleartray://capture")
                )
                setOnClickPendingIntent(R.id.widget_capture_button, captureIntent)

                val openIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("cleartray://inbox")
                )
                setOnClickPendingIntent(R.id.widget_root, openIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
