import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
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
  }
}
