enum AttachmentKind { image, audio, file }

class Attachment {
  const Attachment({
    required this.id,
    required this.itemId,
    required this.kind,
    required this.path,
    required this.createdAt,
    this.name,
    this.sizeBytes,
  });

  final String id;
  final String itemId;
  final AttachmentKind kind;
  final String path; // relative to app docs dir
  final String? name;
  final int? sizeBytes;
  final DateTime createdAt;
}

/// Per-item attachment counts, broken down by kind. Used by list cards to show
/// a media indicator without loading the attachment rows themselves.
class AttachmentSummary {
  const AttachmentSummary({this.images = 0, this.audio = 0, this.files = 0});

  final int images;
  final int audio;
  final int files;

  int get total => images + audio + files;
  bool get isEmpty => total == 0;
}
