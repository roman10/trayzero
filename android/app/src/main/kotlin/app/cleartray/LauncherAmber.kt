package app.cleartray

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen

/** Theme-only entrypoints transfer the system splash without drawing a second screen.
 * Keep class names stable across app upgrades and forward Flutter debug flags. */
abstract class IconLauncherActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        val splash = installSplashScreen()
        super.onCreate(savedInstanceState)
        splash.setKeepOnScreenCondition { true }
        if (MainActivity.bringExistingTaskToFront(this)) {
            finishAndRemoveTask()
            return
        }
        // Stay in this task so Android can transfer the existing splash window.
        // Launcher intents carry NEW_TASK; forwarding it would create another task.
        val taskFlags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK or
            Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_DOCUMENT
        startActivity(Intent(intent).setClass(this, MainActivity::class.java).setFlags(
            (intent.flags and taskFlags.inv()) or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        ))
        finish()
    }
}

class LauncherAmber : IconLauncherActivity()
class LauncherBlue : IconLauncherActivity()
class LauncherCyan : IconLauncherActivity()
class LauncherTeal : IconLauncherActivity()
class LauncherGreen : IconLauncherActivity()
class LauncherViolet : IconLauncherActivity()
class LauncherRose : IconLauncherActivity()
