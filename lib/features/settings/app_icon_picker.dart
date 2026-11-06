import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/app_icon_controller.dart';
import '../../core/appearance_preferences.dart';
import '../../l10n/gen/app_localizations.dart';
import 'app_color_picker.dart';

Future<void> showAppIconPicker(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const AppIconPicker(),
    );

class AppIconPicker extends ConsumerStatefulWidget {
  const AppIconPicker({super.key});
  @override
  ConsumerState<AppIconPicker> createState() => _AppIconPickerState();
}

class _AppIconPickerState extends ConsumerState<AppIconPicker> {
  bool _failed = false;
  Future<void> _select(AppPalette palette) async {
    setState(() => _failed = false);
    final ok = await ref
        .read(appIconControllerProvider.notifier)
        .select(palette);
    if (mounted) setState(() => _failed = !ok);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selection = ref.watch(appIconControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.appIcon,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                Theme.of(context).platform == TargetPlatform.android
                    ? l10n.appIconAndroidDescription
                    : l10n.appIconDescription,
              ),
              const SizedBox(height: 20),
              if (selection.isLoading) const LinearProgressIndicator(),
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final palette in AppPalette.values)
                      SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: Semantics(
                          selected: selection.valueOrNull?.palette == palette,
                          child: OutlinedButton(
                            key: ValueKey('app_icon_${palette.id}'),
                            onPressed: selection.isLoading
                                ? null
                                : () => _select(palette),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              side: BorderSide(
                                color: selection.valueOrNull?.palette == palette
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              children: [
                                ExcludeSemantics(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/icon/app-icons/${palette.id}.png',
                                      width: 56,
                                      height: 56,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  paletteLabel(l10n, palette),
                                  textAlign: TextAlign.center,
                                ),
                                if (selection.valueOrNull?.palette == palette)
                                  const Icon(Icons.check),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_failed) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.appIconChangeFailed,
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              ],
              if (Theme.of(context).platform == TargetPlatform.android) ...[
                const SizedBox(height: 12),
                Text(l10n.appIconNotificationNote),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.done),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
