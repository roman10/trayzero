import AppIntents
import SwiftUI
import WidgetKit

/// Today widget (ADR 0009): today's focused Items with a complete button.
/// Renders the app's `today_snapshot` with queued completions applied
/// optimistically. A snapshot from an earlier local day renders empty: its
/// Items are carry-over until the app republishes.

private let visibleRows = 5

struct TodayRow: Identifiable, Hashable {
    let id: String
    let title: String
    let completed: Bool
}

struct TodayEntry: TimelineEntry {
    let date: Date
    let rows: [TodayRow]
    let more: Int
    let done: Int
}

enum TodaySnapshotReader {
    static func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func pendingCompletionIds() -> Set<String> {
        Set(TrayzeroShared.readQueue(TrayzeroShared.todayCompletionsKey).compactMap { $0["id"] as? String })
    }

    static func entry(at date: Date, maxRows: Int) -> TodayEntry {
        var items: [(String, String)] = []
        var snapshotDone = 0
        var snapshotMore = 0
        if let raw = TrayzeroShared.defaults?.string(forKey: TrayzeroShared.todaySnapshotKey),
           let data = raw.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           json["day"] as? String == dayString(date) {
            for row in json["items"] as? [[String: Any]] ?? [] {
                if let id = row["id"] as? String, !id.isEmpty {
                    items.append((id, row["title"] as? String ?? ""))
                }
            }
            snapshotDone = json["done"] as? Int ?? 0
            snapshotMore = json["more"] as? Int ?? 0
        }
        let pending = pendingCompletionIds()
        let rows = items.map { TodayRow(id: $0.0, title: $0.1, completed: pending.contains($0.0)) }
        return TodayEntry(
            date: date,
            rows: Array(rows.prefix(maxRows)),
            more: snapshotMore + max(0, rows.count - maxRows),
            done: snapshotDone + rows.filter(\.completed).count
        )
    }
}

struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: Date(), rows: [], more: 0, done: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(TodaySnapshotReader.entry(at: Date(), maxRows: rowLimit(context.family)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let now = Date()
        let limit = rowLimit(context.family)
        // A second entry at midnight empties yesterday's list even if the app
        // never runs. The app reloads the timeline whenever focus changes.
        let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(3600)
        completion(Timeline(
            entries: [
                TodaySnapshotReader.entry(at: now, maxRows: limit),
                TodaySnapshotReader.entry(at: midnight, maxRows: limit),
            ],
            policy: .after(midnight)
        ))
    }

    private func rowLimit(_ family: WidgetFamily) -> Int {
        family == .systemLarge ? 8 : 3
    }
}

/// Marks an Item complete from the widget. Runs in the widget extension:
/// queues the tap for the app, which completes the Item when it next runs.
/// WidgetKit reloads the timeline after `perform`, so the row shows done.
@available(iOS 17.0, *)
struct CompleteTodayItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Item"
    static var isDiscoverable = false

    @Parameter(title: "Item")
    var itemId: String

    init() {}

    init(itemId: String) {
        self.itemId = itemId
    }

    func perform() async throws -> some IntentResult {
        if !TodaySnapshotReader.pendingCompletionIds().contains(itemId) {
            TrayzeroShared.append(
                ["id": itemId, "at": TrayzeroShared.nowMillis],
                to: TrayzeroShared.todayCompletionsKey
            )
        }
        return .result()
    }
}

@available(iOS 17.0, *)
struct TrayzeroTodayWidgetView: View {
    var entry: TodayEntry

    /// Brand accent, lighter in dark mode (matches the Android widget).
    private static let brand = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.941, green: 0.541, blue: 0.294, alpha: 1) // #F08A4B
            : UIColor(red: 0.761, green: 0.325, blue: 0.106, alpha: 1) // #C2531B
    })

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Link(destination: URL(string: "cleartray://today")!) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Today")
                        .font(.headline)
                        .foregroundStyle(Self.brand)
                    Spacer()
                    if entry.done > 0 {
                        Text("\(entry.done) done")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if entry.rows.isEmpty {
                emptyState
            } else {
                ForEach(entry.rows) { row in
                    rowView(row)
                }
                Spacer(minLength: 0)
                if entry.more > 0 {
                    Link(destination: URL(string: "cleartray://today")!) {
                        Text("+\(entry.more) more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func rowView(_ row: TodayRow) -> some View {
        HStack(spacing: 8) {
            Button(intent: CompleteTodayItemIntent(itemId: row.id)) {
                Image(systemName: row.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(row.completed ? Self.brand.opacity(0.6) : Self.brand)
            }
            .buttonStyle(.plain)
            .disabled(row.completed)
            .accessibilityLabel(Text("Complete \(row.title)"))
            Link(destination: itemURL(row.id)) {
                Text(row.title)
                    .font(.subheadline)
                    .lineLimit(1)
                    .strikethrough(row.completed)
                    .foregroundStyle(row.completed ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer(minLength: 0)
            Text(entry.done > 0 ? "All done for today" : "Nothing focused yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Link(destination: URL(string: "cleartray://plan")!) {
                Text("Plan your day")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Self.brand, in: Capsule())
            }
            Spacer(minLength: 0)
        }
    }

    private func itemURL(_ id: String) -> URL {
        var components = URLComponents()
        components.scheme = "cleartray"
        components.host = "item"
        components.queryItems = [URLQueryItem(name: "id", value: id)]
        return components.url ?? URL(string: "cleartray://today")!
    }
}

@available(iOS 17.0, *)
struct TrayzeroTodayWidget: Widget {
    let kind: String = "TrayzeroTodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProvider()) { entry in
            TrayzeroTodayWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Today")
        .description("Your focused items for today. Tap a circle to complete.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
