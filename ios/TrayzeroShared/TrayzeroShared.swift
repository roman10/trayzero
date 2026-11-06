import Foundation

/// App Group storage shared by Runner, App Intents, and the widget extension
/// (ADR 0009). Keys match `HomeWidgetBridgeImpl` in Dart, which reads them
/// through home_widget's App Group `UserDefaults`.
enum TrayzeroShared {
    static let appGroupId = "group.app.cleartray"

    static let todaySnapshotKey = "today_snapshot"
    static let todayCompletionsKey = "today_completions"
    static let inboxCapturesKey = "inbox_captures"
    static let pendingLaunchKey = "pending_launch_url"

    static var defaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    /// Queues are JSON arrays stored as strings, so Dart reads them as-is.
    static func readQueue(_ key: String) -> [[String: Any]] {
        guard let raw = defaults?.string(forKey: key),
              let data = raw.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
            return []
        }
        return array.compactMap { $0 as? [String: Any] }
    }

    static func append(_ entry: [String: Any], to key: String) {
        var queue = readQueue(key)
        queue.append(entry)
        guard let data = try? JSONSerialization.data(withJSONObject: queue),
              let raw = String(data: data, encoding: .utf8) else { return }
        defaults?.set(raw, forKey: key)
    }

    static var nowMillis: Int64 { Int64(Date().timeIntervalSince1970 * 1000) }

    /// Asks the app to open [link]. The intent may run in the app or in the
    /// widget extension (the Control Center control), so the link goes
    /// through the App Group; the app picks it up via `LaunchLinkRelay`.
    static func requestLaunch(_ link: String) {
        defaults?.set(link, forKey: pendingLaunchKey)
        NotificationCenter.default.post(name: .trayzeroLaunchRequested, object: nil)
    }

    static func takePendingLaunch() -> String? {
        guard let link = defaults?.string(forKey: pendingLaunchKey) else { return nil }
        defaults?.removeObject(forKey: pendingLaunchKey)
        return link
    }
}

extension Notification.Name {
    /// Posted in-process after `TrayzeroShared.requestLaunch`.
    static let trayzeroLaunchRequested = Notification.Name("app.cleartray.launchRequested")
    /// Posted in-process after an intent queued work for the app to drain.
    static let trayzeroQueueChanged = Notification.Name("app.cleartray.queueChanged")
}
