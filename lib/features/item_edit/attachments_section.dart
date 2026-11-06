import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/system_settings.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/image_viewer.dart';
import '../common/thumbnail_file_image.dart';
import '../common/undo_snack_bar.dart';

class AttachmentsSection extends ConsumerStatefulWidget {
  const AttachmentsSection({required this.itemId, super.key});
  final String itemId;

  @override
  ConsumerState<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<AttachmentsSection> {
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  StreamSubscription<void>? _completeSub;
  bool _recording = false;
  String? _playingId;

  /// Attachments the user removed whose Undo window is still open. Hidden from
  /// the list but not yet deleted from disk / the database.
  final _pendingRemoval = <String>{};

  @override
  void initState() {
    super.initState();
    // Reset the play/pause icon when a memo finishes on its own.
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingId = null);
    });
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 2400,
      maxHeight: 2400,
    );
    if (file == null) return;
    await ref
        .read(attachmentRepositoryProvider)
        .attach(
          itemId: widget.itemId,
          kind: AttachmentKind.image,
          source: File(file.path),
          originalName: p.basename(file.path),
        );
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() => _recording = false);
      if (path == null) return;
      await ref
          .read(attachmentRepositoryProvider)
          .attach(
            itemId: widget.itemId,
            kind: AttachmentKind.audio,
            source: File(path),
            originalName: 'voice memo',
          );
      // Best-effort: temp file cleanup. The repo already copied it.
      final tmp = File(path);
      if (await tmp.exists()) await tmp.delete();
      return;
    }
    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      _showMicrophoneDenied();
      return;
    }
    final tmpDir = await getTemporaryDirectory();
    final tmpPath = p.join(
      tmpDir.path,
      'rec_${ref.read(clockProvider).now().millisecondsSinceEpoch}.m4a',
    );
    await _recorder.start(const RecordConfig(), path: tmpPath);
    setState(() => _recording = true);
  }

  /// Recording needs the microphone; once it is denied the OS will not ask
  /// again, so say why nothing happened and offer the way out.
  void _showMicrophoneDenied() {
    final l10n = AppLocalizations.of(context);
    final settings = ref.read(systemSettingsProvider);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.microphoneAccessDenied),
          action: SnackBarAction(
            label: l10n.notificationActionOpenSettings,
            onPressed: () => unawaited(settings.openAppSettings()),
          ),
        ),
      );
  }

  Future<void> _play(Attachment a) async {
    if (_playingId == a.id) {
      await _player.stop();
      setState(() => _playingId = null);
      return;
    }
    final abs = await ref.read(attachmentRepositoryProvider).absolutePathOf(a);
    if (!mounted) return;
    await _player.stop();
    await _player.play(DeviceFileSource(abs));
    if (!mounted) return;
    setState(() => _playingId = a.id);
  }

  /// Hides [a] and offers Undo; the file and row are deleted only once the
  /// snackbar closes without Undo, so a mis-tap never destroys a photo.
  void _removeWithUndo(Attachment a) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    // Resolved now: the snackbar can outlive this section (and its ref).
    final repo = ref.read(attachmentRepositoryProvider);
    if (_playingId == a.id) {
      unawaited(_player.stop());
      _playingId = null;
    }
    setState(() => _pendingRemoval.add(a.id));
    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(
          undoSnackBar(
            context,
            message: l10n.attachmentRemoved,
            onUndo: () {
              if (mounted) setState(() => _pendingRemoval.remove(a.id));
            },
          ),
        )
        .closed
        .then((reason) async {
          if (reason == SnackBarClosedReason.action) return;
          await repo.delete(a);
          if (mounted) setState(() => _pendingRemoval.remove(a.id));
        })
        .catchError((Object _) {});
  }

  Future<void> _openImage(Attachment tapped, List<Attachment> all) async {
    final imgs = all.where((a) => a.kind == AttachmentKind.image).toList();
    // Capture the position now; the list passed in is the current snapshot.
    final initialIndex = imgs.indexOf(tapped);
    if (initialIndex < 0) return;
    final repo = ref.read(attachmentRepositoryProvider);
    final srcs = [
      for (final a in imgs)
        ViewerImage(
          path: await repo.absolutePathOf(a),
          name: a.name,
          heroTag: a.id,
        ),
    ];
    if (!mounted) return;
    await showImageViewer(context, images: srcs, initialIndex: initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final attachments = [
      for (final a
          in ref.watch(attachmentsForItemProvider(widget.itemId)).valueOrNull ??
              const <Attachment>[])
        if (!_pendingRemoval.contains(a.id)) a,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.image_outlined, size: 18),
              label: Text(l10n.attachmentPhoto),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            ActionChip(
              avatar: const Icon(Icons.camera_alt_outlined, size: 18),
              label: Text(l10n.attachmentCamera),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            ActionChip(
              avatar: Icon(_recording ? Icons.stop : Icons.mic_none, size: 18),
              label: Text(
                _recording ? l10n.attachmentStop : l10n.attachmentVoiceMemo,
              ),
              onPressed: _toggleRecord,
            ),
          ],
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final a in attachments)
            _AttachmentTile(
              attachment: a,
              isPlaying: _playingId == a.id,
              onPlay: () => _play(a),
              onOpenImage: () => _openImage(a, attachments),
              onDelete: () => _removeWithUndo(a),
            ),
        ],
      ],
    );
  }
}

class _AttachmentTile extends ConsumerWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.isPlaying,
    required this.onPlay,
    required this.onOpenImage,
    required this.onDelete,
  });
  final Attachment attachment;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onOpenImage;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: switch (attachment.kind) {
            AttachmentKind.audio => onPlay,
            AttachmentKind.image => onOpenImage,
            AttachmentKind.file => null,
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                FutureBuilder<String>(
                  future: ref
                      .read(attachmentRepositoryProvider)
                      .absolutePathOf(attachment),
                  builder: (_, snap) {
                    if (attachment.kind == AttachmentKind.image &&
                        snap.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Hero(
                          tag: attachment.id,
                          child: Image(
                            image: ThumbnailFileImage(
                              File(snap.data!),
                              pixelSize:
                                  (56 * MediaQuery.devicePixelRatioOf(context))
                                      .ceil(),
                            ),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 56,
                              height: 56,
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(switch (attachment.kind) {
                        AttachmentKind.audio =>
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        AttachmentKind.file => Icons.insert_drive_file,
                        _ => Icons.image_outlined,
                      }, color: scheme.onPrimaryContainer),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name ?? attachment.kind.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _humanSize(attachment.sizeBytes),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.remove,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _humanSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
