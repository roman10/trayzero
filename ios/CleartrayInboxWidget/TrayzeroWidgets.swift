import SwiftUI
import WidgetKit

@main
struct TrayzeroWidgets: WidgetBundle {
    var body: some Widget {
        CleartrayInboxWidget()
        if #available(iOS 17.0, *) {
            TrayzeroTodayWidget()
        }
        if #available(iOS 18.0, *) {
            TrayzeroCaptureControl()
        }
    }
}
