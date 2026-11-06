package app.cleartray

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.UUID
import java.util.concurrent.Executors

class FolderBackupChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "app.cleartray/folder_backup")
    private val storage = FolderBackupStorage(activity.applicationContext)
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pickerResult: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "chooseFolder" -> {
                    if (pickerResult != null) {
                        result.error("busy", "A folder picker is already open", null)
                    } else {
                        pickerResult = result
                        try {
                            activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                            }, REQUEST_FOLDER)
                        } catch (e: Exception) {
                            pickerResult = null
                            result.error("folder", e.message, null)
                        }
                    }
                }
                "listSnapshots", "readSnapshot" -> {
                    val handle = call.argument<String>("handle")
                    val id = call.argument<String>("id")
                    worker.execute {
                        try {
                            require(handle != null)
                            val value: Any = if (call.method == "listSnapshots") {
                                storage.listSnapshots(Uri.parse(handle))
                            } else {
                                require(id != null)
                                storage.readSnapshot(Uri.parse(handle), Uri.parse(id))
                            }
                            main.post { result.success(value) }
                        } catch (e: Exception) {
                            main.post { result.error("folder", e.message, null) }
                        }
                    }
                }
                "writeSnapshot", "releaseFolder" -> {
                    val handle = call.argument<String>("handle")
                    val contents = call.argument<String>("contents")
                    worker.execute {
                        try {
                            require(handle != null)
                            val value: Any? = if (call.method == "writeSnapshot") {
                                require(contents != null)
                                storage.writeSnapshot(Uri.parse(handle), contents)
                            } else {
                                activity.contentResolver.releasePersistableUriPermission(
                                    Uri.parse(handle), Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                                null
                            }
                            main.post { result.success(value) }
                        } catch (e: Exception) {
                            main.post { result.error("folder", e.message, null) }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_FOLDER) return false
        val result = pickerResult ?: return true
        pickerResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        try {
            val flags = data.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            require(flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION != 0)
            activity.contentResolver.takePersistableUriPermission(uri, flags)
            val document = DocumentsContract.buildDocumentUriUsingTree(
                uri, DocumentsContract.getTreeDocumentId(uri))
            val label = activity.contentResolver.query(document,
                arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use {
                if (it.moveToFirst()) it.getString(0) else null
            } ?: DocumentsContract.getTreeDocumentId(uri)
            result.success(mapOf("handle" to uri.toString(), "label" to label))
        } catch (e: Exception) {
            result.error("folder", e.message, null)
        }
        return true
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        pickerResult?.success(null)
        pickerResult = null
        worker.shutdown()
    }

    companion object { private const val REQUEST_FOLDER = 54092 }
}

/** Uses document URIs, never raw paths. Publication must succeed before pruning. */
class FolderBackupStorage(private val context: Context) {
    private val resolver get() = context.contentResolver

    private fun installationId(): String {
        // Excluded from Android's device/cloud restore: two installations must
        // never share retention ownership, even after a phone transfer.
        val file = File(context.noBackupFilesDir, "folder-backup-device-id")
        if (file.exists()) return file.readText().also { require(it.matches(Regex("[a-f0-9]{32}"))) }
        val id = UUID.randomUUID().toString().replace("-", "")
        file.writeText(id)
        return id
    }

    fun writeSnapshot(tree: Uri, contents: String): Boolean {
        require(DocumentsContract.isTreeUri(tree))
        val prefix = "trayzero-auto-${installationId()}-"
        val stamp = SimpleDateFormat("yyyyMMdd'T'HHmmssSSS'Z'", Locale.ROOT).apply {
            timeZone = TimeZone.getTimeZone("UTC")
        }.format(Date())
        val name = "$prefix$stamp-${UUID.randomUUID().toString().replace("-", "")}.json"
        val parent = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
        var pending: Uri? = DocumentsContract.createDocument(resolver, parent,
            "application/json", ".$name.partial") ?: error("Cannot create backup")
        try {
            resolver.openOutputStream(pending!!, "w")?.use { stream ->
                stream.write(contents.toByteArray(Charsets.UTF_8))
                stream.flush()
            } ?: error("Cannot write backup")
            DocumentsContract.renameDocument(resolver, pending!!, name)
                ?: error("The folder provider cannot publish backups")
            pending = null
        } finally {
            pending?.let { try { DocumentsContract.deleteDocument(resolver, it) } catch (_: Exception) {} }
        }
        // A cleanup failure is reported separately; the complete backup exists.
        return try {
            val owned = Regex("${Regex.escape(prefix)}[0-9]{8}T[0-9]{9}Z-[a-f0-9]{32}\\.json")
            val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree,
                DocumentsContract.getTreeDocumentId(tree))
            val snapshots = mutableListOf<Pair<String, Uri>>()
            resolver.query(children, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use { cursor ->
                while (cursor.moveToNext()) {
                    val childName = cursor.getString(1)
                    val childUri = DocumentsContract.buildDocumentUriUsingTree(tree, cursor.getString(0))
                    if (owned.matches(childName) && childName != name) snapshots.add(childName to childUri)
                }
            } ?: error("Cannot list backup history")
            var success = true
            for ((_, uri) in snapshots.sortedByDescending { it.first }.drop(9)) {
                try { if (!DocumentsContract.deleteDocument(resolver, uri)) success = false }
                catch (_: Exception) { success = false }
            }
            success
        } catch (_: Exception) { false }
    }

    /** Trayzero backup files (automatic or manually exported) directly inside [tree]. */
    fun listSnapshots(tree: Uri): List<Map<String, Any>> {
        require(DocumentsContract.isTreeUri(tree))
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree,
            DocumentsContract.getTreeDocumentId(tree))
        val found = mutableListOf<Map<String, Any>>()
        resolver.query(children, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED,
            DocumentsContract.Document.COLUMN_MIME_TYPE), null, null, null)?.use { cursor ->
            while (cursor.moveToNext()) {
                val name = cursor.getString(1) ?: continue
                if (cursor.getString(3) == DocumentsContract.Document.MIME_TYPE_DIR) continue
                if (!SNAPSHOT_NAME.matches(name)) continue
                val uri = DocumentsContract.buildDocumentUriUsingTree(tree, cursor.getString(0))
                found.add(mapOf("id" to uri.toString(), "name" to name,
                    "modified" to (if (cursor.isNull(2)) 0L else cursor.getLong(2))))
            }
        } ?: error("Cannot list backup folder")
        return found
    }

    /** [document] comes from [listSnapshots]; access rides on the tree's persisted grant. */
    fun readSnapshot(tree: Uri, document: Uri): String {
        require(DocumentsContract.isTreeUri(tree))
        // Document ids are opaque for some providers, so only the provider is checked.
        require(document.authority == tree.authority)
        val stream = resolver.openInputStream(document) ?: error("Cannot read backup")
        return stream.use { String(it.readBytes(), Charsets.UTF_8) }
    }

    companion object {
        // Visible backups only: hidden ".partial" files never match.
        private val SNAPSHOT_NAME = Regex("trayzero-(auto|backup)-.*\\.json")
    }
}
