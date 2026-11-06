package app.cleartray

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.app.Activity
import android.app.ActivityManager
import java.lang.ref.WeakReference
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class MainActivity : FlutterActivity() {
    companion object {
        private var liveHost = WeakReference<MainActivity>(null)

        /** A different launcher component must not create a second Flutter engine. */
        fun bringExistingTaskToFront(from: Activity): Boolean {
            val host = liveHost.get() ?: return false
            if (host.isFinishing || host.isDestroyed || host.taskId == from.taskId) return false
            val task = from.getSystemService(ActivityManager::class.java).appTasks
                .firstOrNull { it.taskInfo.taskId == host.taskId } ?: return false
            task.moveToFront()
            return true
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // The manifest supplies a neutral starting window for direct entrypoints.
        // Once native code runs, use the current icon for the compat splash too.
        setTheme(AppIconManager(this).splashTheme())
        installSplashScreen()
        normalizeLink(intent)
        super.onCreate(savedInstanceState)
        liveHost = WeakReference(this)
        AppShortcuts.publish(this)
    }

    override fun onNewIntent(intent: Intent) {
        normalizeLink(intent)
        super.onNewIntent(intent)
    }

    /**
     * Flutter's own deep linking is disabled (ADR 0009), so an external
     * `VIEW cleartray://…` link is routed like a widget launch instead.
     */
    private fun normalizeLink(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW && intent.data?.scheme == "cleartray") {
            intent.action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
        }
    }

    override fun onDestroy() {
        if (liveHost.get() === this) liveHost.clear()
        super.onDestroy()
    }

    private var folderBackup: FolderBackupChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        folderBackup = FolderBackupChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        val icons = AppIconManager(this)
        LaunchLinks.channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LaunchLinks.CHANNEL
        ).apply {
            // iOS holds App Intent links here; Android launches go through
            // home_widget, so there is never a pending link.
            setMethodCallHandler { call, result ->
                if (call.method == "takePending") result.success(null) else result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.cleartray/app_icon")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getState" -> result.success(icons.state())
                    "setIcon" -> {
                        val icon = call.argument<String>("icon")
                        try {
                            requireNotNull(icon) { "Missing app icon" }
                            val state = icons.setIcon(icon)
                            // Shortcuts belong to the launcher alias that is now enabled.
                            AppShortcuts.publish(this)
                            result.success(state)
                        } catch (error: IllegalArgumentException) {
                            result.error("invalid_icon", error.message, null)
                        } catch (error: Exception) {
                            result.error("icon_change_failed", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (folderBackup?.onActivityResult(requestCode, resultCode, data) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        folderBackup?.dispose()
        folderBackup = null
        LaunchLinks.channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
