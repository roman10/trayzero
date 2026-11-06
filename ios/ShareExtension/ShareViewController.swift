import UIKit
import Social
import UniformTypeIdentifiers

/// Receives text/URL shares and saves the receive_sharing_intent wire format
/// before opening the host. The host's SceneDelegate forwards cold/warm URLs.
class ShareViewController: SLComposeServiceViewController {
    private let appGroupId = "group.app.cleartray"
    private let urlScheme = "ShareMedia-app.cleartray" // expected by receive_sharing_intent

    private var posting = false

    override func isContentValid() -> Bool { return !posting }

    override func didSelectPost() {
        guard !posting else { return }
        posting = true
        let attachments = (extensionContext?.inputItems as? [NSExtensionItem] ?? [])
            .flatMap { $0.attachments ?? [] }
        let group = DispatchGroup()
        // Providers finish in arbitrary order and on arbitrary threads. Keep
        // their source order and mutate the result array only on the main queue.
        var collected = Array<String?>(repeating: nil, count: attachments.count)
        let typed = contentText ?? ""
        var loadError: Error?

        for (index, attachment) in attachments.enumerated() {
            if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                group.enter()
                attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { value, error in
                    DispatchQueue.main.async {
                        collected[index] = (value as? URL)?.absoluteString
                        if collected[index] == nil { loadError = error ?? CocoaError(.fileReadUnknown) }
                        group.leave()
                    }
                }
            } else if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                group.enter()
                attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { value, error in
                    DispatchQueue.main.async {
                        collected[index] = value as? String
                        if collected[index] == nil { loadError = error ?? CocoaError(.fileReadUnknown) }
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if let error = loadError {
                self.extensionContext?.cancelRequest(withError: error)
                return
            }
            guard let defaults = UserDefaults(suiteName: self.appGroupId) else {
                self.extensionContext?.cancelRequest(withError: CocoaError(.fileWriteUnknown))
                return
            }
            let text = ([typed] + collected.compactMap { $0 })
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .joined(separator: "\n\n")
            do {
                if try SharePayload.persist(text, to: defaults) { self.openHostApp() }
                self.completeRequest()
            } catch {
                self.extensionContext?.cancelRequest(withError: error)
            }
        }
    }

    override func configurationItems() -> [Any]! { return [] }

    private func openHostApp() {
        guard let url = URL(string: "\(urlScheme)://dataUrl=ShareKey") else { return }
        var responder: UIResponder? = self
        while responder != nil {
            if let app = responder as? UIApplication {
                // Match the plugin's supported redirect paths: iOS 18 no
                // longer accepts the legacy openURL: selector.
                if #available(iOS 18.0, *) {
                    app.open(url, options: [:], completionHandler: nil)
                } else {
                    _ = app.perform(NSSelectorFromString("openURL:"), with: url)
                }
                return
            }
            responder = responder?.next
        }
    }

    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}

/// Kept independent of UIKit so the native tests exercise the exact payload
/// written by the extension against the installed plugin's Codable decoder.
enum SharePayload {
    private struct Media: Encodable {
        let path: String
        let type = "text"
    }

    @discardableResult
    static func persist(_ text: String, to defaults: UserDefaults) throws -> Bool {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return false }
        let data = try JSONEncoder().encode([Media(path: text)])
        defaults.set(data, forKey: "ShareKey")
        defaults.removeObject(forKey: "ShareMessageKey")
        defaults.removeObject(forKey: "shared_text") // obsolete custom format
        defaults.synchronize() // publish before the host process is opened
        return true
    }
}
