import AppIntents

/// "Add to Inbox" from Siri, Shortcuts, Spotlight, or the Action button
/// (ADR 0009). Runs without opening the app: the text is queued in the App
/// Group and lands raw in the Inbox when the app next drains its queue.
@available(iOS 16.0, *)
struct AddToInboxIntent: AppIntent {
    static var title: LocalizedStringResource = "Add to Inbox"
    static var description = IntentDescription("Adds text to your Trayzero Inbox without opening the app.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Text",
        requestValueDialog: IntentDialog("What do you want to capture?")
    )
    var text: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$text) to Inbox")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw $text.needsValueError(IntentDialog("What do you want to capture?"))
        }
        TrayzeroShared.append(
            ["text": trimmed, "at": TrayzeroShared.nowMillis],
            to: TrayzeroShared.inboxCapturesKey
        )
        // Lets a running app drain now rather than on its next resume.
        NotificationCenter.default.post(name: .trayzeroQueueChanged, object: nil)
        return .result(dialog: IntentDialog("Added to your Inbox."))
    }
}

/// Phrases that appear in Shortcuts and Spotlight without setup. Siri
/// requires the app name in every phrase.
@available(iOS 16.0, *)
struct TrayzeroShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddToInboxIntent(),
            phrases: [
                "Add to \(.applicationName) inbox",
                "Capture in \(.applicationName)",
            ],
            shortTitle: "Add to Inbox",
            systemImageName: "tray.and.arrow.down"
        )
        AppShortcut(
            intent: OpenQuickCaptureIntent(),
            phrases: ["Open \(.applicationName) quick capture"],
            shortTitle: "Quick Capture",
            systemImageName: "plus.circle"
        )
        AppShortcut(
            intent: ShowTodayIntent(),
            phrases: ["Show \(.applicationName) Today"],
            shortTitle: "Today",
            systemImageName: "star"
        )
    }
}
