import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../application/automatic_folder_backup.dart';
import '../../core/clock.dart';
import '../../core/folder_backup.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/localized_dates.dart';
import 'folder_backup_controls.dart';

enum _CardKind { healthy, neutral, attention, off }

/// "Backed up 5 minutes ago" for a backup made within the last two calendar
/// days; null when it is older and the caller should show the absolute date.
/// A timestamp slightly in the future (clock skew) reads as "just now".
@visibleForTesting
String? backupRelativeHeadline(
  AppLocalizations l10n,
  DateTime backedUp,
  DateTime now,
) {
  final diff = now.difference(backedUp);
  if (diff.inMinutes < 1) return l10n.backupCardJustNow;
  if (diff.inMinutes < 60) return l10n.backupCardMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.backupCardHoursAgo(diff.inHours);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final day = DateTime(backedUp.year, backedUp.month, backedUp.day);
  if (day == yesterday) return l10n.backupCardYesterday;
  return null;
}

/// The one-glance answer to "are my backups working?", with the single fix
/// for whatever state they are in.
class BackupStatusCard extends ConsumerWidget {
  const BackupStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(automaticFolderBackupProvider);
    final controller = ref.read(automaticFolderBackupProvider.notifier);
    final health = ref.watch(backupHealthProvider);
    final settings = state.settings;
    final folder = settings.folder;
    final lastSuccess = settings.lastSuccess;
    final stale = health == BackupHealth.stale;

    final _CardKind kind;
    final String headline;
    String? body;
    String? exactTime;
    if (!settings.enabled || folder == null) {
      kind = _CardKind.off;
      headline = l10n.folderBackupOff;
      body = l10n.backupCardOffBody;
    } else if (state.failed || stale) {
      kind = _CardKind.attention;
      headline = state.failed
          ? l10n.folderBackupFailed
          : l10n.folderBackupStale(
              ref
                  .watch(clockProvider)
                  .now()
                  .difference(settings.lastHealthy!)
                  .inDays,
            );
      body = l10n.folderBackupRepairHint;
    } else if (lastSuccess == null) {
      kind = _CardKind.neutral;
      headline = l10n.folderBackupNever;
    } else {
      kind = _CardKind.healthy;
      final exact = DateFormat.yMMMd(
        l10n.dateLocaleName,
      ).add_jm().format(lastSuccess.toLocal());
      final relative = backupRelativeHeadline(
        l10n,
        lastSuccess.toLocal(),
        ref.watch(clockProvider).now(),
      );
      // Recent backups read as relative time with the exact moment beneath;
      // older ones fall back to the absolute date as the headline.
      headline = relative ?? l10n.backupCardHealthy(exact);
      if (relative != null) exactTime = exact;
    }
    final detailLines = [
      ?exactTime,
      if (kind == _CardKind.healthy || kind == _CardKind.neutral)
        l10n.restoreFolderFrom(folder!.label),
    ];

    final success =
        (Theme.of(context).extension<GtdColors>() ??
                (scheme.brightness == Brightness.dark
                    ? GtdColors.dark
                    : GtdColors.light))
            .nextAction;
    final (
      Color background,
      Color foreground,
      Color badge,
      IconData icon,
    ) = switch (kind) {
      _CardKind.healthy => (
        Color.alphaBlend(success.withValues(alpha: 0.16), scheme.surface),
        scheme.onSurface,
        success,
        Icons.check_circle_outline,
      ),
      _CardKind.neutral => (
        scheme.surfaceContainerHigh,
        scheme.onSurface,
        scheme.primary,
        Icons.history,
      ),
      _CardKind.attention => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        scheme.onErrorContainer,
        Icons.warning_amber_rounded,
      ),
      _CardKind.off => (
        scheme.surfaceContainerHigh,
        scheme.onSurface,
        scheme.onSurfaceVariant,
        Icons.cloud_off_outlined,
      ),
    };
    final secondary = kind == _CardKind.attention
        ? foreground
        : scheme.onSurfaceVariant;
    final busy = state.busy;
    const buttonSize = Size(48, 48);

    final Widget actions = switch (kind) {
      _CardKind.attention => Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FilledButton(
            onPressed: busy ? null : controller.chooseFolder,
            style: FilledButton.styleFrom(minimumSize: buttonSize),
            child: Text(l10n.backupCardChooseAgain),
          ),
          TextButton(
            onPressed: busy ? null : controller.backUpNow,
            style: TextButton.styleFrom(
              minimumSize: buttonSize,
              foregroundColor: foreground,
            ),
            child: Text(l10n.backupCardTryAgain),
          ),
        ],
      ),
      _CardKind.off => FilledButton(
        onPressed: busy
            ? null
            : () => setAutomaticBackup(controller, settings, true),
        style: FilledButton.styleFrom(minimumSize: buttonSize),
        child: Text(l10n.backupCardTurnOn),
      ),
      _ => FilledButton.tonal(
        onPressed: busy ? null : controller.backUpNow,
        style: FilledButton.styleFrom(minimumSize: buttonSize),
        child: Text(busy ? l10n.folderBackupSaving : l10n.folderBackupNow),
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        key: const ValueKey('backup_status_card'),
        color: background,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: badge.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: badge),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              busy ? l10n.folderBackupSaving : headline,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: foreground,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          for (final line in detailLines) ...[
                            const SizedBox(height: 2),
                            Text(line, style: TextStyle(color: secondary)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (body != null) ...[
                const SizedBox(height: 12),
                Text(body, style: TextStyle(color: secondary, height: 1.35)),
              ],
              if (state.historyWarning) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.folderBackupHistoryWarning,
                  style: TextStyle(color: secondary, height: 1.35),
                ),
              ],
              const SizedBox(height: 16),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}
