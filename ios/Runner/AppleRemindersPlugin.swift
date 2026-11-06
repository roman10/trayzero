import EventKit
import Flutter

/// Public EventKit APIs only. This plugin never saves, completes or removes a
/// reminder, including when the user undoes an import in Trayzero.
final class AppleRemindersPlugin: NSObject, FlutterPlugin {
  private let store = EKEventStore()

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "app.cleartray/apple_reminders", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(AppleRemindersPlugin(), channel: channel)
  }

  private var authorized: Bool {
    let status = EKEventStore.authorizationStatus(for: .reminder)
    if #available(iOS 17.0, *) { return status == .fullAccess }
    return status == .authorized
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestLists":
      requestLists(result)
    case "readReminders":
      guard let args = call.arguments as? [String: Any],
            let ids = args["listIds"] as? [String], !ids.isEmpty else {
        result(FlutterError(code: "lists_changed", message: nil, details: nil))
        return
      }
      readReminders(Set(ids), result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestLists(_ result: @escaping FlutterResult) {
    if authorized { returnListSnapshot(result); return }
    guard EKEventStore.authorizationStatus(for: .reminder) == .notDetermined else {
      result(FlutterError(code: "permission_denied", message: nil, details: nil))
      return
    }
    let completion: (Bool, Error?) -> Void = { [self] granted, error in
      DispatchQueue.main.async {
        if granted && self.authorized {
          self.returnListSnapshot(result)
        } else {
          result(FlutterError(code: Self.accessFailureCode(
            status: EKEventStore.authorizationStatus(for: .reminder), error: error),
            message: nil, details: nil))
        }
      }
    }
    if #available(iOS 17.0, *) {
      store.requestFullAccessToReminders(completion: completion)
    } else {
      store.requestAccess(to: .reminder, completion: completion)
    }
  }

  /// A denied/restricted authorization is actionable even when EventKit also
  /// supplies an error. Show Settings recovery rather than a generic retry.
  static func accessFailureCode(status: EKAuthorizationStatus, error: Error?) -> String {
    if status == .denied || status == .restricted || error == nil {
      return "permission_denied"
    }
    return "read_failed"
  }

  private func returnListSnapshot(_ result: FlutterResult) {
    // The account name disambiguates equal list names from iCloud/Exchange.
    let lists = store.calendars(for: .reminder).sorted {
      ($0.title, $0.calendarIdentifier) < ($1.title, $1.calendarIdentifier)
    }
    result(lists.map { ["id": $0.calendarIdentifier, "title": $0.title,
                       "account": $0.source.title] })
  }

  private func readReminders(_ ids: Set<String>, _ result: @escaping FlutterResult) {
    guard authorized else {
      result(FlutterError(code: "permission_denied", message: nil, details: nil))
      return
    }
    let lists = store.calendars(for: .reminder).filter { ids.contains($0.calendarIdentifier) }
    guard Set(lists.map(\.calendarIdentifier)) == ids else {
      result(FlutterError(code: "lists_changed", message: nil, details: nil))
      return
    }
    let predicate = store.predicateForReminders(in: lists)
    store.fetchReminders(matching: predicate) { [self] reminders in
      DispatchQueue.main.async {
        guard self.authorized else {
          result(FlutterError(code: "permission_denied", message: nil, details: nil))
          return
        }
        guard let reminders = reminders else {
          result(FlutterError(code: "read_failed", message: nil, details: nil))
          return
        }
        let currentIds = Set(self.store.calendars(for: .reminder).map(\.calendarIdentifier))
        guard ids.isSubset(of: currentIds) else {
          result(FlutterError(code: "lists_changed", message: nil, details: nil))
          return
        }
        result(reminders.filter { ids.contains($0.calendar.calendarIdentifier) }
          .sorted { ($0.calendar.calendarIdentifier, $0.title ?? "", $0.calendarItemIdentifier)
                    < ($1.calendar.calendarIdentifier, $1.title ?? "", $1.calendarItemIdentifier) }
          .map(AppleRemindersSnapshot.encode))
      }
    }
  }
}

/// Separated from permissions and the channel so native date/recurrence
/// semantics can be tested without granting access to someone's reminders.
enum AppleRemindersSnapshot {
  static func encode(_ reminder: EKReminder) -> [String: Any] {
    var value: [String: Any] = [
      "id": reminder.calendarItemIdentifier,
      "listId": reminder.calendar.calendarIdentifier,
      "title": reminder.title ?? "",
      "completed": reminder.isCompleted,
      "dueIsDateOnly": reminder.dueDateComponents?.hour == nil,
      "recurrenceRules": (reminder.recurrenceRules ?? []).map(recurrenceText),
      "hasAlarms": !(reminder.alarms ?? []).isEmpty,
      "priority": reminder.priority
    ]
    value["notes"] = reminder.notes
    value["url"] = reminder.url?.absoluteString
    value["due"] = dateText(reminder.dueDateComponents)
    value["start"] = dateText(reminder.startDateComponents)
    return value
  }

  static func dateText(_ components: DateComponents?) -> String? {
    guard let components = components else { return nil }
    var calendar = components.calendar ?? Calendar(identifier: .gregorian)
    calendar.timeZone = components.timeZone ?? .current
    guard let date = calendar.date(from: components) else { return nil }
    if components.hour == nil {
      // Convert non-Gregorian components before sending a Gregorian ISO date.
      var gregorian = Calendar(identifier: .gregorian)
      gregorian.timeZone = calendar.timeZone
      let day = gregorian.dateComponents([.year, .month, .day], from: date)
      return String(format: "%04d-%02d-%02d", day.year!, day.month!, day.day!)
    }
    return ISO8601DateFormatter().string(from: date)
  }

  static func recurrenceText(_ rule: EKRecurrenceRule) -> String {
    let frequencies: [EKRecurrenceFrequency: String] = [
      .daily: "DAILY", .weekly: "WEEKLY", .monthly: "MONTHLY", .yearly: "YEARLY"]
    guard let frequency = frequencies[rule.frequency],
          rule.calendarIdentifier == "gregorian" else { return rule.description }
    var parts = ["FREQ=\(frequency)", "INTERVAL=\(rule.interval)"]
    let weekdays = ["", "SU", "MO", "TU", "WE", "TH", "FR", "SA"]
    if let days = rule.daysOfTheWeek, !days.isEmpty {
      parts.append("BYDAY=" + days.map {
        ($0.weekNumber == 0 ? "" : String($0.weekNumber)) + weekdays[$0.dayOfTheWeek.rawValue]
      }.joined(separator: ","))
    }
    for (key, numbers) in [("BYMONTHDAY", rule.daysOfTheMonth),
                           ("BYMONTH", rule.monthsOfTheYear),
                           ("BYWEEKNO", rule.weeksOfTheYear),
                           ("BYYEARDAY", rule.daysOfTheYear),
                           ("BYSETPOS", rule.setPositions)] {
      if let numbers = numbers, !numbers.isEmpty {
        parts.append(key + "=" + numbers.map(\.stringValue).joined(separator: ","))
      }
    }
    if rule.firstDayOfTheWeek > 0 && rule.firstDayOfTheWeek < weekdays.count {
      parts.append("WKST=" + weekdays[rule.firstDayOfTheWeek])
    }
    if let end = rule.recurrenceEnd {
      if end.occurrenceCount > 0 { parts.append("COUNT=\(end.occurrenceCount)") }
      if let date = end.endDate {
        parts.append("UNTIL=" + ISO8601DateFormatter().string(from: date))
      }
    }
    return parts.joined(separator: ";")
  }
}
