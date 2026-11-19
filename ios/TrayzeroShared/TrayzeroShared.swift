import Darwin
import Foundation

/// App Group storage shared by Runner, App Intents, and the widget extension
/// (ADR 0009). Widget snapshots and launch links use App Group preferences.
/// Pending actions use files in the same App Group.
enum TrayzeroShared {
    static let appGroupId = "group.app.cleartray"

    static let todaySnapshotKey = "today_snapshot"
    static let todayCompletionsKey = "today_completions"
    static let inboxCapturesKey = "inbox_captures"
    static let pendingLaunchKey = "pending_launch_url"

    static var defaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    static func readQueue(_ key: String) -> [[String: Any]] {
        (try? withQueueLock(key) { url in try loadQueue(key, at: url) }) ?? []
    }

    @discardableResult
    static func append(_ entry: [String: Any], to key: String) -> Bool {
        do {
            try withQueueLock(key) { url in
                var queue = try loadQueue(key, at: url)
                if key == todayCompletionsKey, let id = entry["id"] as? String,
                   queue.contains(where: { $0["id"] as? String == id }) {
                    return
                }
                var pending = entry
                pending["receipt"] = UUID().uuidString
                queue.append(pending)
                try saveQueue(queue, at: url)
            }
            return true
        } catch {
            NSLog("Trayzero external queue: could not save %@", key)
            return false
        }
    }

    static func encodedQueue(_ key: String) throws -> String {
        try withQueueLock(key) { url in
            let data = try JSONSerialization.data(withJSONObject: loadQueue(key, at: url))
            return String(decoding: data, as: UTF8.self)
        }
    }

    static func acknowledge(_ receipts: Set<String>, in key: String) throws {
        try withQueueLock(key) { url in
            let queue = try loadQueue(key, at: url)
            let remaining = queue.filter { entry in
                guard let receipt = entry["receipt"] as? String else { return true }
                return !receipts.contains(receipt)
            }
            if remaining.count != queue.count {
                try saveQueue(remaining, at: url)
            }
        }
    }

    /// Preferences are cached per process. Coordinate the extension and app
    /// with a separate lock file and atomically replace the queue under it.
    private static func withQueueLock<T>(_ key: String, _ body: (URL) throws -> T) throws -> T {
        guard key == todayCompletionsKey || key == inboxCapturesKey else {
            throw CocoaError(.fileReadInvalidFileName)
        }
        let files = FileManager.default
        guard let group = files.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            throw CocoaError(.fileNoSuchFile)
        }
        let folder = group.appendingPathComponent("external-queue", isDirectory: true)
        try files.createDirectory(at: folder, withIntermediateDirectories: true)
        let lockURL = folder.appendingPathComponent("\(key).lock")
        let fd = Darwin.open(lockURL.path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard fd >= 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
        defer { close(fd) }
        guard flock(fd, LOCK_EX) == 0 else {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
        }
        return try body(folder.appendingPathComponent("\(key).json"))
    }

    private static func loadQueue(_ key: String, at url: URL) throws -> [[String: Any]] {
        if FileManager.default.fileExists(atPath: url.path) {
            let data = try Data(contentsOf: url)
            guard let queue = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw CocoaError(.fileReadCorruptFile)
            }
            return queue
        }
        guard let raw = defaults?.string(forKey: key),
              let data = raw.data(using: .utf8),
              let legacy = (try? JSONSerialization.jsonObject(with: data)) as? [Any] else {
            return []
        }
        let migrated = legacy.compactMap { entry -> [String: Any]? in
            guard var values = entry as? [String: Any] else { return nil }
            values["receipt"] = UUID().uuidString
            return values
        }
        // Once this file exists the legacy array is never read again, even if
        // the last entry is acknowledged or the app exits during migration.
        try saveQueue(migrated, at: url)
        defaults?.removeObject(forKey: key)
        return migrated
    }

    private static func saveQueue(_ queue: [[String: Any]], at url: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: queue)
        try data.write(to: url, options: .atomic)
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
