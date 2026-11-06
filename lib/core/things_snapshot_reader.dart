import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads a user-selected export copy, never a running Things database.
abstract interface class ThingsSnapshotReader {
  Map<String, List<Map<String, Object?>>> read(List<int> bytes);
}

final thingsSnapshotReaderProvider = Provider<ThingsSnapshotReader>((ref) {
  throw UnimplementedError('thingsSnapshotReaderProvider must be wired');
});
