package app.cleartray

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/** Quick Settings tile "Capture to Trayzero" (ADR 0009): opens the capture sheet. */
class CaptureTileService : TileService() {
    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            label = getString(R.string.tile_capture_label)
            contentDescription = label
            state = Tile.STATE_INACTIVE
            updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        if (isLocked) unlockAndRun { openCapture() } else openCapture()
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    private fun openCapture() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(LaunchLinks.pendingIntent(this, LINK))
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(
                LaunchLinks.intent(this, LINK).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            )
        }
    }

    private companion object {
        const val LINK = "cleartray://capture"
    }
}
