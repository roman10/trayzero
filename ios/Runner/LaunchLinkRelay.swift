import Flutter
import UIKit

/// Delivers `cleartray://` links to Dart over `app.cleartray/launch_link`
/// (ADR 0009). Sources: scene URLs (widget taps, typed links) at cold and
/// warm start, and App Intents via `TrayzeroShared.requestLaunch`.
///
/// A link that arrives before Dart asks (`takePending`) is held; later links
/// are pushed with `open`. Flutter's own deep linking is disabled in
/// Info.plist, so go_router never sees the raw URL.
final class LaunchLinkRelay: NSObject, FlutterSceneLifeCycleDelegate {
    static let shared = LaunchLinkRelay()

    private var channel: FlutterMethodChannel?
    private var pending: String?
    private var dartReady = false

    private override init() {
        super.init()
        let center = NotificationCenter.default
        center.addObserver(forName: .trayzeroLaunchRequested, object: nil, queue: .main) { [weak self] _ in
            if let link = TrayzeroShared.takePendingLaunch() { self?.deliver(link) }
        }
        center.addObserver(forName: .trayzeroQueueChanged, object: nil, queue: .main) { [weak self] _ in
            guard let self = self, self.dartReady else { return }
            self.channel?.invokeMethod("queueChanged", arguments: nil)
        }
    }

    func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "app.cleartray/launch_link", binaryMessenger: registrar.messenger())
        self.channel = channel
        // A new engine (e.g. hot restart) must ask again before links are pushed.
        dartReady = false
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return result(nil) }
            switch call.method {
            case "takePending":
                self.dartReady = true
                let link = self.pending ?? TrayzeroShared.takePendingLaunch()
                self.pending = nil
                result(link)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        registrar.addSceneDelegate(self)
    }

    static func isAppLink(_ url: URL) -> Bool { url.scheme == "cleartray" }

    func deliver(_ link: String) {
        if dartReady, let channel = channel {
            channel.invokeMethod("open", arguments: link)
        } else {
            pending = link
        }
    }

    // MARK: FlutterSceneLifeCycleDelegate

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
        let links = connectionOptions?.urlContexts.map(\.url).filter(Self.isAppLink) ?? []
        links.forEach { deliver($0.absoluteString) }
        return !links.isEmpty
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        let links = URLContexts.map(\.url).filter(Self.isAppLink)
        links.forEach { deliver($0.absoluteString) }
        return !links.isEmpty
    }
}
