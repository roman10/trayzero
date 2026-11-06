import AppIntents

/// App Intents that open the app (ADR 0009). Compiled into Runner and the
/// widget extension so the Control Center control can run them; the system
/// runs them in the app process because they open it.
@available(iOS 16.0, *)
struct OpenQuickCaptureIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Quick Capture"
    static var description = IntentDescription("Opens Trayzero's quick capture sheet.")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        TrayzeroShared.requestLaunch("cleartray://capture")
        return .result()
    }
}

@available(iOS 16.0, *)
struct ShowTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Today"
    static var description = IntentDescription("Opens the items you focused for today.")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        TrayzeroShared.requestLaunch("cleartray://today")
        return .result()
    }
}
