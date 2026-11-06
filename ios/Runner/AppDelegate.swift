import Flutter
import UIKit
import UserNotifications
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var appIconChannel: FlutterMethodChannel?
  private var iconChangeInProgress = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Notification actions can start a separate headless Flutter engine.
    // Register its plugins too: the implicit UI engine's registry is not
    // shared, and Done/Move need path_provider to persist their action journal.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    // The UIScene lifecycle (FlutterSceneDelegate) does not wire the
    // UNUserNotificationCenter delegate, so flutter_local_notifications never
    // received foreground presentations, taps, or action-button responses.
    // FlutterAppDelegate is a UNUserNotificationCenterDelegate and forwards
    // these to plugins registered via addApplicationDelegate, so point the
    // center at it. Required for local notifications to surface and route.
    UNUserNotificationCenter.current().delegate = self
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FolderBackupPlugin") {
      FolderBackupPlugin.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppleRemindersPlugin") {
      AppleRemindersPlugin.register(with: registrar)
    }
    // cleartray:// links and App Intent launches (ADR 0009).
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TrayzeroLaunchLink") {
      LaunchLinkRelay.shared.register(with: registrar)
    }
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TrayzeroAppIcon") else { return }
    let channel = FlutterMethodChannel(name: "app.cleartray/app_icon", binaryMessenger: registrar.messenger())
    appIconChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch call.method {
        case "getState": result(self.appIconState())
        case "setIcon":
          guard let arguments = call.arguments as? [String: Any],
                let icon = arguments["icon"] as? String,
                ["amber", "blue", "cyan", "teal", "green", "violet", "rose"].contains(icon) else {
            result(FlutterError(code: "invalid_icon", message: "Unknown app icon", details: nil))
            return
          }
          guard UIApplication.shared.supportsAlternateIcons,
                UIApplication.shared.applicationState == .active,
                !self.iconChangeInProgress else {
            result(FlutterError(code: "icon_unavailable", message: "App icon cannot be changed right now", details: nil))
            return
          }
          let name: String? = icon == "amber" ? nil : "AppIcon-\(icon)"
          if UIApplication.shared.alternateIconName == name {
            result(self.appIconState())
            return
          }
          self.iconChangeInProgress = true
          UIApplication.shared.setAlternateIconName(name) { error in
            DispatchQueue.main.async {
              self.iconChangeInProgress = false
              if let error = error {
                result(FlutterError(code: "icon_change_failed", message: error.localizedDescription, details: nil))
              } else {
                result(self.appIconState())
              }
            }
          }
        default: result(FlutterMethodNotImplemented)
        }
      }
    }
  }

  private func appIconState() -> [String: Any] {
    let current = UIApplication.shared.alternateIconName
    return [
      "supported": UIApplication.shared.supportsAlternateIcons,
      "icon": current?.replacingOccurrences(of: "AppIcon-", with: "") ?? "amber"
    ]
  }

}
