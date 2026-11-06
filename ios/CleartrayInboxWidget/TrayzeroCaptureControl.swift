import AppIntents
import SwiftUI
import WidgetKit

/// Control Center / Lock Screen / Action button control (ADR 0009) that
/// opens quick capture. `OpenQuickCaptureIntent` is compiled into Runner too,
/// so the system performs it in the app it opens.
@available(iOS 18.0, *)
struct TrayzeroCaptureControl: ControlWidget {
    static let kind = "app.cleartray.CaptureControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenQuickCaptureIntent()) {
                Label("Capture to Trayzero", systemImage: "tray.and.arrow.down")
            }
        }
        .displayName("Capture to Trayzero")
        .description("Opens Trayzero's quick capture sheet.")
    }
}
