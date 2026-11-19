import AppIntents
import SwiftUI
import WidgetKit

/// Today widget (ADR 0009): today's focused Items with a complete button.
/// Renders the app's `today_snapshot` with queued completions applied
/// optimistically. A snapshot from an earlier local day renders empty: its
/// Items are carry-over until the app republishes.

struct TodayRow: Identifiable, Hashable {
    let id: String
    let title: String
    let pending: Bool
}

struct TodayEntry: TimelineEntry {
    let date: Date
    let rows: [TodayRow]
    let more: Int
    let done: Int
    var isPreview = false

    var pendingCount: Int {
        rows.filter(\.pending).count
    }
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

    static func entry(at date: Date) -> TodayEntry {
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
        let rows = items.map { TodayRow(id: $0.0, title: $0.1, pending: pending.contains($0.0)) }
        return TodayEntry(date: date, rows: rows, more: snapshotMore, done: snapshotDone)
    }
}

struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        previewEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(context.isPreview ? previewEntry() : TodaySnapshotReader.entry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let now = Date()
        // A second entry at midnight empties yesterday's list even if the app
        // never runs. The app reloads the timeline whenever focus changes.
        let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(3600)
        completion(Timeline(
            entries: [
                TodaySnapshotReader.entry(at: now),
                TodaySnapshotReader.entry(at: midnight),
            ],
            policy: .after(midnight)
        ))
    }

    private func previewEntry() -> TodayEntry {
        let titles = [
            String(localized: "Review notes"),
            String(localized: "Send the agenda"),
            String(localized: "Water the plants"),
            String(localized: "Plan tomorrow"),
        ]
        let rows = titles.enumerated().map {
            TodayRow(id: "preview-\($0.offset)", title: $0.element, pending: false)
        }
        return TodayEntry(date: Date(), rows: rows, more: 0, done: 1, isPreview: true)
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

    @Environment(\.widgetContentMargins) private var margins

    private static let todayURL = URL(string: "cleartray://today")!
    private static let planURL = URL(string: "cleartray://plan")!
    private static let completionTarget: CGFloat = 44

    /// Brand accent, lighter in dark mode (matches the Android widget).
    private static let brand = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.941, green: 0.541, blue: 0.294, alpha: 1) // #F08A4B
            : UIColor(red: 0.761, green: 0.325, blue: 0.106, alpha: 1) // #C2531B
    })

    var body: some View {
        Group {
            if entry.rows.isEmpty && entry.more == 0 {
                VStack(alignment: .leading, spacing: 6) {
                    header
                    emptyState
                }
            } else {
                ViewThatFits(in: .vertical) {
                    ForEach((0...entry.rows.count).reversed(), id: \.self) { count in
                        taskList(showing: count)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Leave room for two full touch targets and the overflow link in a medium widget.
        .padding(EdgeInsets(
            top: min(margins.top, 8),
            leading: margins.leading,
            bottom: min(margins.bottom, 8),
            trailing: margins.trailing
        ))
    }

    private var header: some View {
        widgetLink(to: Self.todayURL) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("Today")
                    .font(.headline)
                    .foregroundStyle(Self.brand)
                Spacer(minLength: 0)
                if entry.done > 0 {
                    Text("\(entry.done) done")
                }
                if entry.pendingCount > 0 {
                    Text("\(entry.pendingCount) pending")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
        }
    }

    private func taskList(showing count: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            header
            if count > 0 {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(entry.rows.prefix(count)) { row in
                        rowView(row)
                    }
                }
            }
            let remaining = entry.more + entry.rows.count - count
            if remaining > 0 {
                widgetLink(to: Self.todayURL) {
                    Text("+\(remaining) more")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    private func rowView(_ row: TodayRow) -> some View {
        HStack(spacing: 4) {
            if entry.isPreview {
                checkmark(row)
                    .accessibilityHidden(true)
            } else if row.pending {
                checkmark(row)
                    .accessibilityLabel(Text("Completion pending for \(row.title)"))
            } else {
                Button(intent: CompleteTodayItemIntent(itemId: row.id)) {
                    checkmark(row)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Complete \(row.title)"))
            }
            widgetLink(to: itemURL(row.id)) {
                Text(row.title)
                    .font(.subheadline)
                    .lineLimit(1)
                    .strikethrough(row.pending)
                    .foregroundStyle(row.pending ? .secondary : .primary)
                    .frame(maxWidth: .infinity, minHeight: Self.completionTarget, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
    }

    private func checkmark(_ row: TodayRow) -> some View {
        Image(systemName: row.pending ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(row.pending ? Self.brand.opacity(0.6) : Self.brand)
            .frame(width: Self.completionTarget, height: Self.completionTarget)
            .contentShape(Rectangle())
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer(minLength: 0)
            Text(entry.done > 0 ? "All done for today" : "Nothing focused yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            widgetLink(to: Self.planURL) {
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

    @ViewBuilder
    private func widgetLink<Label: View>(to url: URL, @ViewBuilder label: () -> Label) -> some View {
        if entry.isPreview {
            label()
        } else {
            Link(destination: url, label: label)
        }
    }

    private func itemURL(_ id: String) -> URL {
        var components = URLComponents()
        components.scheme = "cleartray"
        components.host = "item"
        components.queryItems = [URLQueryItem(name: "id", value: id)]
        return components.url ?? Self.todayURL
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
        .contentMarginsDisabled()
        .configurationDisplayName("Today")
        .description("Your focused items for today. Tap a circle to complete.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
