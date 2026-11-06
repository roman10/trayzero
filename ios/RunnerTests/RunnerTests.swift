import EventKit
import Flutter
import UIKit
import XCTest
import receive_sharing_intent
@testable import Runner

class RunnerTests: XCTestCase {

  func testSharePayloadMatchesInstalledPluginDecoder() throws {
    let suite = "trayzero-share-test-" + UUID().uuidString
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    defaults.set("stale message", forKey: "ShareMessageKey")
    let text = "Read this 👩🏽‍💻\n\nhttps://example.com/?share=123"
    XCTAssertTrue(try SharePayload.persist(text, to: defaults))
    let data = try XCTUnwrap(defaults.data(forKey: "ShareKey"))
    let media = try JSONDecoder().decode([SharedMediaFile].self, from: data)
    let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(media)) as! [[String: Any]]
    XCTAssertEqual(json.count, 1)
    XCTAssertEqual(json[0]["path"] as? String, text)
    XCTAssertEqual(json[0]["type"] as? String, "text")
    XCTAssertNil(defaults.object(forKey: "ShareMessageKey"))
    XCTAssertFalse(try SharePayload.persist(" \n ", to: defaults))
    XCTAssertEqual(defaults.data(forKey: "ShareKey"), data)
  }

  func testSharingURLIsRegisteredAndDeliveredOnColdAndWarmLaunch() throws {
    let schemes = (Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as! [[String: Any]])
      .flatMap { $0["CFBundleURLSchemes"] as? [String] ?? [] }
    XCTAssertTrue(schemes.contains("ShareMedia-app.cleartray"))
    let defaults = UserDefaults(suiteName: "group.app.cleartray")!
    let old = defaults.object(forKey: "ShareKey")
    let plugin = SwiftReceiveSharingIntentPlugin.instance
    defer {
      defaults.set(old, forKey: "ShareKey")
      _ = plugin.onCancel(withArguments: nil)
      plugin.handle(FlutterMethodCall(methodName: "reset", arguments: nil)) { _ in }
    }
    let url = URL(string: "ShareMedia-app.cleartray://dataUrl=ShareKey")!
    try SharePayload.persist("cold-share", to: defaults)
    XCTAssertTrue(SceneDelegate.handleShareURL(url, initial: true))
    var initial: String?
    plugin.handle(FlutterMethodCall(methodName: "getInitialMedia", arguments: nil)) {
      initial = $0 as? String
    }
    XCTAssertTrue(try XCTUnwrap(initial).contains("cold-share"))
    var received: String?
    _ = plugin.onListen(withArguments: nil) { received = $0 as? String }
    try SharePayload.persist("warm-share", to: defaults)
    XCTAssertTrue(SceneDelegate.handleShareURL(url, initial: false))
    XCTAssertTrue(try XCTUnwrap(received).contains("warm-share"))
    XCTAssertFalse(SceneDelegate.handleShareURL(URL(string: "cleartray://inbox")!, initial: false))
  }

  func testFolderBackupsRetainOnlyOwnHistoryAndKeepLatestSnapshot() throws {
    let files = FileManager.default
    let root = files.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try files.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? files.removeItem(at: root) }
    let unrelated = root.appendingPathComponent("personal.json")
    try Data("personal".utf8).write(to: unrelated)
    let otherDevice = root.appendingPathComponent(
      "trayzero-auto-ffffffffffffffffffffffffffffffff-20260101T000000000Z-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.json")
    try Data("other device".utf8).write(to: otherDevice)
    let id = "0123456789abcdef0123456789abcdef"
    for i in 0..<12 {
      XCTAssertTrue(try FolderBackupStorage.publish(in: root,
        contents: "{\"version\":6,\"iteration\":\(i)}", installationId: id))
    }
    let all = try files.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
    let snapshots = all.filter { $0.lastPathComponent.hasPrefix("trayzero-auto-\(id)-") }
    XCTAssertEqual(snapshots.count, 10)
    XCTAssertEqual(all.count, 12)
    XCTAssertEqual(try String(contentsOf: unrelated, encoding: .utf8), "personal")
    XCTAssertEqual(try String(contentsOf: otherDevice, encoding: .utf8), "other device")
    let decoded = try snapshots.map {
      try JSONSerialization.jsonObject(with: Data(contentsOf: $0)) as! [String: Int]
    }
    XCTAssertTrue(decoded.contains { $0["iteration"] == 11 })
    XCTAssertFalse(all.contains { $0.lastPathComponent.contains("partial") })
    XCTAssertThrowsError(try FolderBackupStorage.publish(
      in: root.appendingPathComponent("missing"), contents: "{}", installationId: id))
    XCTAssertEqual(try files.contentsOfDirectory(atPath: root.path).count, 12)
  }

  func testFolderBackupListsAndReadsOnlyTrayzeroSnapshots() throws {
    let files = FileManager.default
    let root = files.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try files.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? files.removeItem(at: root) }
    try Data("personal".utf8).write(to: root.appendingPathComponent("personal.json"))
    try Data("{}".utf8).write(to: root.appendingPathComponent(".trayzero-auto-x.json.partial"))
    try Data("{\"version\":6}".utf8).write(to: root.appendingPathComponent("trayzero-backup-2026-10-16T12-34-56.json"))
    XCTAssertTrue(try FolderBackupStorage.publish(in: root, contents: "{\"version\":6,\"n\":1}",
      installationId: "0123456789abcdef0123456789abcdef"))
    let listed = try FolderBackupStorage.list(in: root)
    XCTAssertEqual(listed.count, 2)
    let names = listed.map { $0["name"] as! String }
    XCTAssertTrue(names.contains("trayzero-backup-2026-10-16T12-34-56.json"))
    XCTAssertEqual(try FolderBackupStorage.read(in: root, name: "trayzero-backup-2026-10-16T12-34-56.json"),
                   "{\"version\":6}")
    XCTAssertThrowsError(try FolderBackupStorage.read(in: root, name: "personal.json"))
    XCTAssertThrowsError(try FolderBackupStorage.read(in: root, name: "../trayzero-backup-x.json"))
  }

  func testAppleRemindersDatesKeepDateOnlyAndTimedMidnightDistinct() {
    let zone = TimeZone(secondsFromGMT: 8 * 3600)!
    var allDay = DateComponents()
    allDay.calendar = Calendar(identifier: .gregorian)
    allDay.timeZone = zone
    allDay.year = 2026
    allDay.month = 11
    allDay.day = 5
    XCTAssertEqual(AppleRemindersSnapshot.dateText(allDay), "2026-11-05")
    var timed = allDay
    timed.hour = 0
    timed.minute = 0
    XCTAssertEqual(AppleRemindersSnapshot.dateText(timed), "2026-11-04T16:00:00Z")
    XCTAssertNil(AppleRemindersSnapshot.dateText(nil))
  }

  func testAppleRemindersSnapshotIncludesSourceFieldsWithoutSaving() {
    let store = EKEventStore()
    let reminder = EKReminder(eventStore: store)
    reminder.calendar = EKCalendar(for: .reminder, eventStore: store)
    reminder.title = "Call Mum 日本語"
    reminder.notes = "Bring photos"
    reminder.url = URL(string: "https://example.com")
    reminder.priority = 1
    reminder.addAlarm(EKAlarm(relativeOffset: -600))
    reminder.dueDateComponents = DateComponents(year: 2026, month: 11, day: 5)
    reminder.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil))
    let snapshot = AppleRemindersSnapshot.encode(reminder)
    XCTAssertEqual(snapshot["title"] as? String, "Call Mum 日本語")
    XCTAssertEqual(snapshot["notes"] as? String, "Bring photos")
    XCTAssertEqual(snapshot["url"] as? String, "https://example.com")
    XCTAssertEqual(snapshot["due"] as? String, "2026-11-05")
    XCTAssertEqual(snapshot["dueIsDateOnly"] as? Bool, true)
    XCTAssertEqual(snapshot["hasAlarms"] as? Bool, true)
    XCTAssertEqual(snapshot["priority"] as? Int, 1)
    XCTAssertEqual(snapshot["completed"] as? Bool, false)
    let rules = snapshot["recurrenceRules"] as? [String]
    XCTAssertEqual(rules?.count, 1)
    XCTAssertTrue(rules?.first?.hasPrefix("FREQ=WEEKLY;INTERVAL=2") == true)
    XCTAssertFalse(reminder.isCompleted)
    XCTAssertTrue(reminder.hasChanges) // No writes to the source store.
  }

  func testAppleReminderComplexRecurrenceRetainsEveryQualifier() {
    let rule = EKRecurrenceRule(recurrenceWith: .monthly, interval: 2,
      daysOfTheWeek: [EKRecurrenceDayOfWeek(.tuesday, weekNumber: 2)],
      daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil,
      daysOfTheYear: nil, setPositions: [1, -1], end: EKRecurrenceEnd(occurrenceCount: 10))
    let text = AppleRemindersSnapshot.recurrenceText(rule)
    XCTAssertTrue(text.contains("FREQ=MONTHLY;INTERVAL=2"))
    XCTAssertTrue(text.contains("BYDAY=2TU"))
    XCTAssertTrue(text.contains("BYSETPOS=1,-1"))
    XCTAssertTrue(text.contains("COUNT=10"))
  }

  func testAppleRemindersEmptySelectionNeverReadsAllLists() {
    let plugin = AppleRemindersPlugin()
    var replies = 0
    let invalidArguments: [Any] = [["listIds": [String]()], ["listIds": "wrong type"], [:]]
    for arguments in invalidArguments {
      plugin.handle(FlutterMethodCall(methodName: "readReminders", arguments: arguments)) { response in
        replies += 1
        XCTAssertEqual((response as? FlutterError)?.code, "lists_changed")
      }
    }
    XCTAssertEqual(replies, 3)
  }

  func testDeniedReminderPermissionWithAnErrorStillOffersSettingsRecovery() {
    let error = NSError(domain: EKErrorDomain, code: 29)
    XCTAssertEqual(AppleRemindersPlugin.accessFailureCode(status: .denied, error: error),
      "permission_denied")
    XCTAssertEqual(AppleRemindersPlugin.accessFailureCode(status: .restricted, error: error),
      "permission_denied")
    XCTAssertEqual(AppleRemindersPlugin.accessFailureCode(status: .notDetermined, error: error),
      "read_failed")
    XCTAssertEqual(AppleRemindersPlugin.accessFailureCode(status: .denied, error: nil),
      "permission_denied")
  }

}
