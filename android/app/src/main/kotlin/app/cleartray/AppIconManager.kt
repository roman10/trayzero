package app.cleartray

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build

/** Only launcher entries are toggled. MainActivity and all native entrypoints stay enabled. */
class AppIconManager(private val context: Context) {
    private val palettes = listOf("amber", "blue", "cyan", "teal", "green", "violet", "rose")
    private val manager get() = context.packageManager

    private fun component(icon: String) = ComponentName(
        context.packageName,
        "app.cleartray.Launcher" + icon.replaceFirstChar { it.uppercaseChar() }
    )

    private fun enabled(icon: String): Boolean = when (manager.getComponentEnabledSetting(component(icon))) {
        PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
        PackageManager.COMPONENT_ENABLED_STATE_DEFAULT -> icon == "amber"
        else -> false
    }

    fun state(): Map<String, Any> = mapOf(
        "supported" to true,
        "icon" to (palettes.drop(1).firstOrNull { enabled(it) } ?: "amber")
    )

    /** Read OS selection before Flutter starts; never drive the launcher from a cache. */
    fun splashTheme(): Int = when (state()["icon"]) {
        "amber" -> R.style.LaunchTheme_Amber
        "blue" -> R.style.LaunchTheme_Blue
        "cyan" -> R.style.LaunchTheme_Cyan
        "teal" -> R.style.LaunchTheme_Teal
        "green" -> R.style.LaunchTheme_Green
        "violet" -> R.style.LaunchTheme_Violet
        "rose" -> R.style.LaunchTheme_Rose
        else -> R.style.LaunchTheme
    }

    fun setIcon(icon: String): Map<String, Any> {
        require(icon in palettes) { "Unknown app icon" }
        val previous = palettes.associateWith { manager.getComponentEnabledSetting(component(it)) }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                // One atomic operation prevents a missing/duplicate launcher entry.
                manager.setComponentEnabledSettings(palettes.map {
                    PackageManager.ComponentEnabledSetting(
                        component(it),
                        if (it == icon) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                        else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                    )
                })
            } else {
                // Older Android: always enable the new entry before disabling the old one.
                manager.setComponentEnabledSetting(component(icon), PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP)
                palettes.filter { it != icon }.forEach {
                    manager.setComponentEnabledSetting(component(it), PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
                }
            }
        } catch (error: Exception) {
            // Best effort rollback; restore an enabled entry before the others.
            val ordered = palettes.sortedBy { if (previous[it] == PackageManager.COMPONENT_ENABLED_STATE_ENABLED || (previous[it] == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT && it == "amber")) 0 else 1 }
            ordered.forEach {
                try { manager.setComponentEnabledSetting(component(it), previous.getValue(it), PackageManager.DONT_KILL_APP) }
                catch (_: Exception) { /* Keep the original failure. */ }
            }
            throw error
        }
        return state()
    }
}
