package app.cleartray

import android.content.ComponentName
import android.content.Context
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Log

/**
 * Launcher long-press shortcuts (ADR 0009). Dynamic rather than static: static
 * shortcuts need a literal target package (the debug build is `.debug`) and
 * launch with CLEAR_TASK, which would destroy a running Flutter engine.
 * Attached to the enabled icon alias (ADR 0005); republished at launch and after
 * an icon change so labels follow the system language.
 */
object AppShortcuts {
    fun publish(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) return
        val manager = context.getSystemService(ShortcutManager::class.java) ?: return
        val icon = AppIconManager(context).state()["icon"] as String
        val activity = ComponentName(
            context.packageName,
            "app.cleartray.Launcher" + icon.replaceFirstChar { it.uppercaseChar() }
        )
        fun shortcut(id: String, link: String, short: Int, long: Int, glyph: Int) =
            ShortcutInfo.Builder(context, id)
                .setActivity(activity)
                .setShortLabel(context.getString(short))
                .setLongLabel(context.getString(long))
                .setIcon(Icon.createWithResource(context, glyph))
                .setIntent(LaunchLinks.intent(context, link))
                .build()
        try {
            manager.dynamicShortcuts = listOf(
                shortcut("capture", "cleartray://capture", R.string.shortcut_capture_short, R.string.shortcut_capture_long, R.drawable.ic_shortcut_capture),
                shortcut("today", "cleartray://today", R.string.shortcut_today_short, R.string.shortcut_today_long, R.drawable.ic_shortcut_today),
                shortcut("process", "cleartray://process", R.string.shortcut_process_short, R.string.shortcut_process_long, R.drawable.ic_shortcut_process),
            )
        } catch (error: Exception) {
            // Rate limits or a launcher without shortcut support: never block launch.
            Log.w("AppShortcuts", "publish failed", error)
        }
    }
}
