import WidgetKit
import SwiftUI

private let appGroupId = "group.app.cleartray"
private let inboxCountKey = "inbox_count"

struct InboxEntry: TimelineEntry {
    let date: Date
    let count: Int
}

struct InboxProvider: TimelineProvider {
    func placeholder(in context: Context) -> InboxEntry {
        InboxEntry(date: Date(), count: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (InboxEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InboxEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh hourly. The Flutter side also requests a manual update on
        // every inbox-count change via HomeWidget.updateWidget.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date) ?? entry.date
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func currentEntry() -> InboxEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let count = defaults?.integer(forKey: inboxCountKey) ?? 0
        return InboxEntry(date: Date(), count: count)
    }
}

struct CleartrayInboxWidgetEntryView: View {
    var entry: InboxEntry

    private static let brand = Color(red: 0.824, green: 0.376, blue: 0.122) // #D2601F brand seed

    /// iOS 17 adds system content margins around widget content.
    private static var contentPadding: CGFloat {
        if #available(iOSApplicationExtension 17.0, *) { return 0 }
        return 14
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.count)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                Text(entry.count == 1 ? "item in Inbox" : "items in Inbox")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                HStack {
                    Spacer()
                    Link(destination: URL(string: "cleartray://capture")!) {
                        Text("+ Capture")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.25))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
            }
            .padding(Self.contentPadding)
        }
        .inboxWidgetBackground(Self.brand)
        .widgetURL(URL(string: "cleartray://inbox"))
    }
}

private extension View {
    /// iOS 17 requires `containerBackground`; without it the widget shows
    /// "Please adopt containerBackground API" instead of its content.
    @ViewBuilder
    func inboxWidgetBackground(_ color: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) { color }
        } else {
            background(color)
        }
    }
}

struct CleartrayInboxWidget: Widget {
    let kind: String = "CleartrayInboxWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InboxProvider()) { entry in
            CleartrayInboxWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Trayzero Inbox")
        .description("See your unprocessed inbox count and capture in one tap.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
