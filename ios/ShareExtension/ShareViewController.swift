import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

/// Receives text/URL shares from any iOS app and forwards them to the
/// Trayzero host app through the App Group container, then opens the host
/// app via the `cleartray://capture?text=…` URL so the capture sheet appears
/// with the shared text pre-filled.
///
/// The `receive_sharing_intent` Flutter plugin reads from the same App Group;
/// the host app picks up the payload as soon as it launches.
class ShareViewController: SLComposeServiceViewController {
    private let appGroupId = "group.app.cleartray"
    private let urlScheme = "ShareMedia-app.cleartray" // expected by receive_sharing_intent

    override func isContentValid() -> Bool { return true }

    override func didSelectPost() {
        guard let item = (extensionContext?.inputItems as? [NSExtensionItem])?.first,
              let attachments = item.attachments else {
            completeRequest()
            return
        }

        let group = DispatchGroup()
        var collected: [String] = []
        if let typed = contentText, !typed.isEmpty { collected.append(typed) }

        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                group.enter()
                attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { value, _ in
                    if let url = value as? URL {
                        collected.append(url.absoluteString)
                    }
                    group.leave()
                }
            } else if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                group.enter()
                attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { value, _ in
                    if let text = value as? String {
                        collected.append(text)
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.persist(collected.joined(separator: "\n\n"))
            self?.openHostApp()
            self?.completeRequest()
        }
    }

    override func configurationItems() -> [Any]! { return [] }

    private func persist(_ text: String) {
        guard let defaults = UserDefaults(suiteName: appGroupId) else { return }
        defaults.set(text, forKey: "shared_text")
        // receive_sharing_intent expects an array under this key
        defaults.set([["path": text, "type": 0]], forKey: "ShareKey")
    }

    private func openHostApp() {
        guard let url = URL(string: "\(urlScheme)://dataUrl=ShareKey") else { return }
        var responder: UIResponder? = self
        while responder != nil {
            if let app = responder as? UIApplication {
                app.perform(#selector(UIApplication.open(_:options:completionHandler:)),
                            with: url)
                return
            }
            responder = responder?.next
        }
    }

    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
