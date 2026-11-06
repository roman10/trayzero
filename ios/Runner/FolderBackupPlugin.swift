import Flutter
import UIKit
import UniformTypeIdentifiers

final class FolderBackupPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
  private let registrar: FlutterPluginRegistrar
  private let worker = DispatchQueue(label: "app.cleartray.folder-backup")
  private var pickerResult: FlutterResult?

  init(registrar: FlutterPluginRegistrar) { self.registrar = registrar }

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FolderBackupPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: FlutterMethodChannel(
      name: "app.cleartray/folder_backup", binaryMessenger: registrar.messenger()))
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "chooseFolder":
      guard pickerResult == nil, var presenter = registrar.viewController else {
        result(FlutterError(code: "folder", message: "Cannot open folder picker", details: nil))
        return
      }
      while let presented = presenter.presentedViewController { presenter = presented }
      pickerResult = result
      let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
      picker.delegate = self
      presenter.present(picker, animated: true)
    case "writeSnapshot":
      guard let args = call.arguments as? [String: Any],
            let handle = args["handle"] as? String,
            let contents = args["contents"] as? String else {
        result(FlutterError(code: "folder", message: "Invalid backup arguments", details: nil))
        return
      }
      // Allow a best-effort foreground save to finish after the user leaves.
      var task: UIBackgroundTaskIdentifier = .invalid
      task = UIApplication.shared.beginBackgroundTask(withName: "Folder backup") {
        if task != .invalid { UIApplication.shared.endBackgroundTask(task); task = .invalid }
      }
      worker.async {
        let outcome: Result<Bool, Error> = Result {
          try FolderBackupStorage.writeSnapshot(bookmark: handle, contents: contents)
        }
        DispatchQueue.main.async {
          if task != .invalid { UIApplication.shared.endBackgroundTask(task); task = .invalid }
          switch outcome {
          case .success(let pruned): result(pruned)
          case .failure(let error):
            result(FlutterError(code: "folder", message: error.localizedDescription, details: nil))
          }
        }
      }
    case "listSnapshots", "readSnapshot":
      guard let args = call.arguments as? [String: Any],
            let handle = args["handle"] as? String else {
        result(FlutterError(code: "folder", message: "Invalid backup arguments", details: nil))
        return
      }
      let name = args["id"] as? String
      let listing = call.method == "listSnapshots"
      worker.async {
        let outcome: Result<Any, Error> = Result { () throws -> Any in
          if listing { return try FolderBackupStorage.listSnapshots(bookmark: handle) as Any }
          guard let name else { throw CocoaError(.fileReadInvalidFileName) }
          return try FolderBackupStorage.readSnapshot(bookmark: handle, name: name) as Any
        }
        DispatchQueue.main.async {
          switch outcome {
          case .success(let value): result(value)
          case .failure(let error):
            result(FlutterError(code: "folder", message: error.localizedDescription, details: nil))
          }
        }
      }
    case "releaseFolder": result(nil) // Bookmarks have no persistent grant to release.
    default: result(FlutterMethodNotImplemented)
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    pickerResult?(nil)
    pickerResult = nil
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    let result = pickerResult
    pickerResult = nil
    guard let url = urls.first, url.startAccessingSecurityScopedResource() else {
      result?(FlutterError(code: "folder", message: "Folder access was denied", details: nil))
      return
    }
    defer { url.stopAccessingSecurityScopedResource() }
    do {
      let bookmark = try url.bookmarkData(options: .minimalBookmark,
        includingResourceValuesForKeys: nil, relativeTo: nil)
      result?(["handle": bookmark.base64EncodedString(), "label": url.lastPathComponent])
    } catch {
      result?(FlutterError(code: "folder", message: error.localizedDescription, details: nil))
    }
  }
}

enum FolderBackupStorage {
  private static func installationId() throws -> String {
    let files = FileManager.default
    var root = try files.url(for: .applicationSupportDirectory, in: .userDomainMask,
      appropriateFor: nil, create: true).appendingPathComponent("FolderBackup", isDirectory: true)
    try files.createDirectory(at: root, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try root.setResourceValues(values)
    let file = root.appendingPathComponent("device-id")
    if files.fileExists(atPath: file.path) {
      let id = try String(contentsOf: file, encoding: .utf8)
      guard id.range(of: "^[a-f0-9]{32}$", options: .regularExpression) != nil else {
        throw CocoaError(.fileReadCorruptFile)
      }
      return id
    }
    let id = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    try Data(id.utf8).write(to: file, options: .atomic)
    return id
  }

  static func writeSnapshot(bookmark: String, contents: String) throws -> Bool {
    guard let data = Data(base64Encoded: bookmark) else { throw CocoaError(.fileReadCorruptFile) }
    var stale = false
    let folder = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &stale)
    guard !stale, folder.startAccessingSecurityScopedResource() else {
      throw CocoaError(.fileWriteNoPermission)
    }
    defer { folder.stopAccessingSecurityScopedResource() }
    return try publish(in: folder, contents: contents, installationId: installationId())
  }

  // Kept separate from bookmark resolution so native tests can exercise actual
  // coordinated writes, retention ownership, and failed publication in temp dirs.
  static func publish(in folder: URL, contents: String, installationId: String) throws -> Bool {
    let prefix = "trayzero-auto-\(installationId)-"
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyyMMdd'T'HHmmssSSS'Z'"
    let unique = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    let name = "\(prefix)\(formatter.string(from: Date()))-\(unique).json"
    var coordinationError: NSError?
    var writeError: Error?
    var pruned = true
    // Coordinate the directory because publication and retention change several
    // of its children. File providers observe the whole completed operation.
    NSFileCoordinator().coordinate(writingItemAt: folder, options: [], error: &coordinationError) { directory in
      let url = directory.appendingPathComponent(name)
      let files = FileManager.default
      let pending = url.deletingLastPathComponent().appendingPathComponent(".\(name).partial")
      do {
        defer { try? files.removeItem(at: pending) }
        try Data(contents.utf8).write(to: pending, options: .atomic)
        try files.moveItem(at: pending, to: url)
      } catch { writeError = error; return }
      do {
        let owned = "^\(prefix)[0-9]{8}T[0-9]{9}Z-[a-f0-9]{32}\\.json$"
        let snapshots = try files.contentsOfDirectory(at: url.deletingLastPathComponent(),
          includingPropertiesForKeys: [.isRegularFileKey]).filter {
            $0.lastPathComponent != name
              && $0.lastPathComponent.range(of: owned, options: .regularExpression) != nil
              && (try? $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true
          }.sorted { $0.lastPathComponent > $1.lastPathComponent }
        for old in snapshots.dropFirst(9) {
          do { try files.removeItem(at: old) } catch { pruned = false }
        }
      } catch { pruned = false }
    }
    if let error = coordinationError ?? (writeError as NSError?) { throw error }
    return pruned
  }

  private static func scopedFolder(bookmark: String) throws -> URL {
    guard let data = Data(base64Encoded: bookmark) else { throw CocoaError(.fileReadCorruptFile) }
    var stale = false
    let folder = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &stale)
    guard !stale, folder.startAccessingSecurityScopedResource() else {
      throw CocoaError(.fileReadNoPermission)
    }
    return folder
  }

  static func listSnapshots(bookmark: String) throws -> [[String: Any]] {
    let folder = try scopedFolder(bookmark: bookmark)
    defer { folder.stopAccessingSecurityScopedResource() }
    return try list(in: folder)
  }

  static func readSnapshot(bookmark: String, name: String) throws -> String {
    let folder = try scopedFolder(bookmark: bookmark)
    defer { folder.stopAccessingSecurityScopedResource() }
    return try read(in: folder, name: name)
  }

  /// Visible Trayzero backups (automatic or manually exported); hidden
  /// ".partial" files never match. Coordinated so a provider can materialize
  /// the directory listing first.
  static func list(in folder: URL) throws -> [[String: Any]] {
    var coordinationError: NSError?
    var failure: Error?
    var found: [[String: Any]] = []
    NSFileCoordinator().coordinate(readingItemAt: folder, options: [], error: &coordinationError) { directory in
      do {
        let urls = try FileManager.default.contentsOfDirectory(at: directory,
          includingPropertiesForKeys: [.isRegularFileKey, .contentModificationDateKey])
        for url in urls {
          // An iCloud Drive file that is not downloaded yet appears as the
          // placeholder ".<name>.icloud"; offer it under its real name and let
          // the coordinated read in read(in:name:) download it.
          let name = realName(of: url.lastPathComponent)
          guard isSnapshotName(name) else { continue }
          let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .contentModificationDateKey])
          guard values?.isRegularFile == true else { continue }
          let modified = values?.contentModificationDate?.timeIntervalSince1970 ?? 0
          found.append(["id": name, "name": name, "modified": Int(modified * 1000)])
        }
      } catch { failure = error }
    }
    if let error = coordinationError ?? (failure as NSError?) { throw error }
    return found
  }

  static func read(in folder: URL, name: String) throws -> String {
    // A plain file name only: never let a caller escape the chosen folder.
    guard isSnapshotName(name), !name.contains("/") else { throw CocoaError(.fileReadInvalidFileName) }
    var coordinationError: NSError?
    var failure: Error?
    var contents = ""
    NSFileCoordinator().coordinate(readingItemAt: folder.appendingPathComponent(name),
                                   options: [], error: &coordinationError) { url in
      do { contents = try String(contentsOf: url, encoding: .utf8) } catch { failure = error }
    }
    if let error = coordinationError ?? (failure as NSError?) { throw error }
    return contents
  }

  private static func realName(of fileName: String) -> String {
    guard fileName.hasPrefix("."), fileName.hasSuffix(".icloud") else { return fileName }
    return String(fileName.dropFirst().dropLast(".icloud".count))
  }

  private static func isSnapshotName(_ name: String) -> Bool {
    name.range(of: "^trayzero-(auto|backup)-.*\\.json$", options: .regularExpression) != nil
  }
}
