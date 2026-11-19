package app.cleartray

import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.RemoteViews
import android.widget.TextView
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class TodayWidgetProviderTest {
    private val instrumentation = InstrumentationRegistry.getInstrumentation()
    private val context = instrumentation.targetContext
    private val rows = List(8) { index ->
        TodayWidgetProvider.Row("item-$index", "Task $index", pending = index == 0)
    }

    @Test
    fun minimumHeightFitsOneCheckboxAndTheOverflowLink() = onMain {
        val widget = inflate(TodayWidgetProvider.Snapshot(rows, 2, 1), 110)
        assertEquals(1, widget.findViewById<LinearLayout>(R.id.today_rows).childCount)
        val overflow = widget.findViewById<TextView>(R.id.today_more)
        assertEquals(context.getString(R.string.today_widget_more, 9), overflow.text)
        assertTrue(overflow.isClickable)
        assertTrue(overflow.height >= pixels(24))
        val checkbox = widget.findViewById<View>(R.id.today_row_check)
        assertEquals(pixels(48), checkbox.width)
        assertEquals(pixels(48), checkbox.height)
        assertTrue(widget.visibleHeightContains(overflow))
        assertTrue(widget.visibleHeightContains(checkbox))
    }

    @Test
    fun pendingCheckboxExposesItsStateAndDoesNotRepeatTheAction() = onMain {
        val widget = inflate(TodayWidgetProvider.Snapshot(rows, 0, 3), 360)
        val rendered = widget.findViewById<LinearLayout>(R.id.today_rows)
        assertTrue(rendered.childCount > 1)
        val pending = rendered.getChildAt(0).findViewById<View>(R.id.today_row_check)
        assertEquals(
            context.getString(R.string.today_widget_completion_pending, rows[0].title),
            pending.contentDescription
        )
        assertFalse(pending.isClickable)
        val open = rendered.getChildAt(1).findViewById<View>(R.id.today_row_check)
        assertEquals(context.getString(R.string.today_widget_complete, rows[1].title), open.contentDescription)
        assertTrue(open.isClickable)
        assertEquals(
            context.getString(R.string.today_widget_pending, 1),
            widget.findViewById<TextView>(R.id.today_status).text
        )
    }

    @Test
    fun expandingAndShrinkingReplaceTheRowsAndOverflow() = onMain {
        val snapshot = TodayWidgetProvider.Snapshot(rows.subList(0, 3), 0, 0)
        val widget = inflate(snapshot, 200)
        val rendered = widget.findViewById<LinearLayout>(R.id.today_rows)
        val overflow = widget.findViewById<TextView>(R.id.today_more)
        assertEquals(3, rendered.childCount)
        assertEquals(View.GONE, overflow.visibility)

        TodayWidgetProvider.viewsAtHeight(context, snapshot, 110f).reapply(context, widget)
        widget.measureAndLayout(110)
        assertEquals(1, rendered.childCount)
        assertEquals(View.VISIBLE, overflow.visibility)
        assertEquals(context.getString(R.string.today_widget_more, 2), overflow.text)
        assertTrue(widget.visibleHeightContains(overflow))
    }

    @Test
    fun widgetPickerPreviewInflatesWithSampleRows() = onMain {
        val preview = RemoteViews(context.packageName, R.layout.trayzero_today_widget_preview)
            .apply(context, FrameLayout(context))
        val root = preview as LinearLayout
        assertEquals(4, root.childCount)
        assertEquals(
            context.getString(R.string.today_widget_preview_task_one),
            (root.getChildAt(1) as TextView).text
        )
    }

    private fun inflate(snapshot: TodayWidgetProvider.Snapshot, height: Int): View =
        TodayWidgetProvider.viewsAtHeight(context, snapshot, height.toFloat())
            .apply(context, FrameLayout(context))
            .also { it.measureAndLayout(height) }

    private fun View.measureAndLayout(height: Int) {
        val widthPx = pixels(180)
        val heightPx = pixels(height)
        measure(
            View.MeasureSpec.makeMeasureSpec(widthPx, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(heightPx, View.MeasureSpec.EXACTLY)
        )
        layout(0, 0, widthPx, heightPx)
    }

    private fun View.visibleHeightContains(child: View): Boolean {
        val rootLocation = IntArray(2)
        val childLocation = IntArray(2)
        getLocationInWindow(rootLocation)
        child.getLocationInWindow(childLocation)
        val childTop = childLocation[1] - rootLocation[1]
        return childTop >= 0 && childTop + child.height <= height
    }

    private fun pixels(dp: Int) = Math.round(dp * context.resources.displayMetrics.density)

    private fun onMain(block: () -> Unit) = instrumentation.runOnMainSync(block)
}
