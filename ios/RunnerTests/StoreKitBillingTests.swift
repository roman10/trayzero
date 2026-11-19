import Flutter
import StoreKit
import StoreKitTest
import XCTest
@testable import Runner

@available(iOS 17.0, *)
@MainActor
final class StoreKitBillingTests: XCTestCase {
  func testRecoversExistingSubscriptionAndRestoresIt() async throws {
    let session = try makeSession()
    session.clearTransactions()
    defer { session.clearTransactions() }

    for id in ["supporter_monthly", "supporter_yearly"] {
      session.clearTransactions()
      // An already finished App Store purchase, with no state in the new gateway.
      let purchase = try await session.buyProduct(identifier: id)
      await purchase.finish()
      let plugin = try await configurePlugin()
      let initial = try await status(plugin, "currentStatus")
      let restored = try await status(plugin, "restore")
      XCTAssertEqual(initial["productId"] as? String, id)
      XCTAssertEqual(restored["productId"] as? String, id)
      XCTAssertNotNil(restored["expiresAtMs"] as? Int64)
      XCTAssertEqual(session.allTransactions().count, 1)
    }
  }

  func testTipsCanBeBoughtAgainAndDoNotRestoreSupporterStatus() async throws {
    let session = try makeSession()
    session.clearTransactions()
    defer { session.clearTransactions() }

    let plugin = try await configurePlugin()
    let catalog = try await call(plugin, "products") as? [[String: Any]]
    XCTAssertEqual(Set(catalog?.compactMap { $0["id"] as? String } ?? []),
      ["tip_small", "tip_large", "supporter_monthly", "supporter_yearly"])
    for _ in 0..<2 {
      let tip = try await status(plugin, "purchase", "tip_small")
      XCTAssertTrue(tip.isEmpty)
    }
    let restored = try await status(plugin, "restore")
    XCTAssertTrue(restored.isEmpty)
    XCTAssertEqual(session.allTransactions().filter { $0.productIdentifier == "tip_small" }.count, 2)
  }

  private func makeSession() throws -> SKTestSession {
    let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "Trayzero", withExtension: "storekit"))
    let session = try SKTestSession(contentsOf: url)
    session.resetToDefaultState()
    session.disableDialogs = true
    return session
  }

  private func configurePlugin() async throws -> TrayzeroStoreKitPlugin {
    let channel = FlutterMethodChannel(name: "storekit-test", binaryMessenger: StoreKitTestMessenger())
    let plugin = TrayzeroStoreKitPlugin(channel: channel)
    _ = try await call(plugin, "configure", [
      "tips": ["tip_small", "tip_large"],
      "subscriptions": ["supporter_monthly", "supporter_yearly"],
    ])
    return plugin
  }

  private func status(_ plugin: TrayzeroStoreKitPlugin, _ method: String, _ arguments: Any? = nil) async throws -> [String: Any] {
    let result = try await call(plugin, method, arguments)
    return try XCTUnwrap(result as? [String: Any])
  }

  private func call(_ plugin: TrayzeroStoreKitPlugin, _ method: String, _ arguments: Any? = nil) async throws -> Any? {
    let response: Any? = await withCheckedContinuation { continuation in
      plugin.handle(FlutterMethodCall(methodName: method, arguments: arguments)) {
        continuation.resume(returning: $0)
      }
    }
    if let error = response as? FlutterError {
      throw NSError(domain: "StoreKitBillingTests", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "\(method): \(error.code)",
      ])
    }
    return response
  }
}


// The plugin may publish a transaction update while the test is awaiting a
// reply. There is no running Dart isolate in this native test.
private final class StoreKitTestMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}
  func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) {
    callback?(nil)
  }
  func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection {
    1
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}
