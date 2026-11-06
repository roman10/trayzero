import Flutter
import UIKit
import receive_sharing_intent

class SceneDelegate: FlutterSceneDelegate {
    /// The plugin only implements UIApplicationDelegate URL callbacks. Scene
    /// apps must forward sharing URLs explicitly, including cold launch data
    /// before Flutter requests getInitialMedia.
    @discardableResult
    static func handleShareURL(_ url: URL, initial: Bool) -> Bool {
        let plugin = SwiftReceiveSharingIntentPlugin.instance
        guard plugin.hasMatchingSchemePrefix(url: url) else { return false }
        if initial {
            return plugin.application(UIApplication.shared,
                didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.url: url])
        }
        return plugin.application(UIApplication.shared, open: url, options: [:])
    }

    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                        options connectionOptions: UIScene.ConnectionOptions) {
        for context in connectionOptions.urlContexts {
            Self.handleShareURL(context.url, initial: true)
        }
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let remaining = Set(URLContexts.filter { !Self.handleShareURL($0.url, initial: false) })
        if !remaining.isEmpty { super.scene(scene, openURLContexts: remaining) }
    }
}
