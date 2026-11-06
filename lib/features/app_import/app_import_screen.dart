import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/import/import_plan.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/readable_page_body.dart';
import 'app_import_controller.dart';
import 'import_source_catalog.dart';

/// Settings → Import from another app (ADR 0008): a grouped list of sources.
/// Each row opens that source's page (`AppImportSourceScreen`), which holds
/// the steps, preview, import and undo.
class AppImportScreen extends ConsumerWidget {
  const AppImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sources = ref.watch(appImportSourcesProvider);
    final groups = [
      (ImportSourceGroup.direct, l10n.importGroupDirect),
      (ImportSourceGroup.file, l10n.importGroupFile),
      (ImportSourceGroup.paste, l10n.importGroupOther),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importFromApp)),
      body: ReadablePageBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.importListIntro, style: theme.textTheme.bodyMedium),
            for (final (group, label) in groups)
              if (sources.any((s) => importSpec(s).group == group)) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                  child: Semantics(
                    header: true,
                    child: Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                _SourceGroup(
                  sources: [
                    for (final s in sources)
                      if (importSpec(s).group == group) s,
                  ],
                ),
              ],
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.importBackupFooter,
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  style: const ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size(64, 48)),
                  ),
                  onPressed: () => context.push('/settings/backup'),
                  child: Text(l10n.importBackupFooterLink),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded container of source rows, separated by thin dividers.
class _SourceGroup extends StatelessWidget {
  const _SourceGroup({required this.sources});
  final List<ImportSourceApp> sources;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < sources.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
                color: scheme.outlineVariant,
              ),
            _SourceRow(source: sources[i]),
          ],
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.source});
  final ImportSourceApp source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spec = importSpec(source);
    final name = spec.name(l10n);
    final method = switch (spec.method) {
      ImportMethod.onDevice => l10n.importChipOnDevice,
      ImportMethod.signIn => l10n.importChipSignIn,
      null => null,
    };
    // At large text the trailing chip would squeeze the name; stack it.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 24;
    final chip = method == null
        ? null
        : Chip(
            label: Text(method),
            visualDensity: VisualDensity.compact,
            side: BorderSide.none,
            backgroundColor: scheme.surfaceContainerHighest,
          );
    return InkWell(
      onTap: () => context.push('/settings/import/${source.name}'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _initials(name),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleMedium),
                    Text(
                      spec.subtitle(l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (stacked && chip != null) chip,
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (chip != null && !stacked) ...[chip, const SizedBox(width: 4)],
              ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to two letters standing in for a brand logo: "Things 3" → "T3",
/// "Plain text / TaskPaper" → "PT", "Todoist" → "To".
String _initials(String name) {
  final words = name
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) {
    final w = words.first;
    return w.characters.take(2).toString();
  }
  return (words[0].characters.first + words[1].characters.first).toUpperCase();
}
