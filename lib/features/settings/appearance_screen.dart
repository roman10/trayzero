import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/app_icon_controller.dart';
import '../../application/appearance_controller.dart';
import '../../core/appearance_preferences.dart';
import '../../l10n/gen/app_localizations.dart';
import 'app_color_picker.dart';
import 'app_icon_picker.dart';
import 'settings_controller.dart';
import 'settings_tiles.dart';

/// Theme mode, app color (inline swatches), app icon and haptics.
class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  bool _paletteSaveFailed = false;
  int _paletteRevision = 0;

  Future<void> _setMode(AppearanceMode mode) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await ref.read(appearanceProvider.notifier).setMode(mode);
    if (!saved) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.appearanceSaveFailed)),
      );
    }
  }

  Future<void> _setPalette(AppPalette palette) async {
    if (palette == ref.read(appearanceProvider).palette) return;
    final revision = ++_paletteRevision;
    setState(() => _paletteSaveFailed = false);
    final saved = await ref
        .read(appearanceProvider.notifier)
        .setPalette(palette);
    if (mounted && revision == _paletteRevision) {
      setState(() => _paletteSaveFailed = !saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final appearance = ref.watch(appearanceProvider);
    final iconState = ref.watch(appIconControllerProvider).valueOrNull;
    final haptics = ref.watch(hapticsEnabledProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceSection)),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        children: [
          SettingsGroup(
            label: l10n.themeLabel,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppearanceMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: AppearanceMode.system,
                        label: Text(
                          l10n.themeFollowSystem,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ButtonSegment(
                        value: AppearanceMode.light,
                        label: Text(l10n.themeLight),
                      ),
                      ButtonSegment(
                        value: AppearanceMode.dark,
                        label: Text(l10n.themeDark),
                      ),
                    ],
                    selected: {appearance.mode},
                    onSelectionChanged: (s) => _setMode(s.first),
                  ),
                ),
              ),
            ],
          ),
          SettingsGroup(
            label: l10n.appColor,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.appColorDescription,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    PaletteOptions(
                      selected: appearance.palette,
                      onSelect: _setPalette,
                    ),
                    if (_paletteSaveFailed) ...[
                      const SizedBox(height: 12),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.appearanceSaveFailed,
                          style: TextStyle(color: scheme.error),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SettingsGroup(
            children: [
              if (iconState?.supported == true)
                SettingsRow(
                  icon: Icons.app_registration_outlined,
                  title: l10n.appIcon,
                  trailingText: paletteLabel(l10n, iconState!.palette),
                  onTap: () => showAppIconPicker(context),
                ),
              SettingsSwitchRow(
                icon: Icons.vibration_outlined,
                title: l10n.hapticFeedback,
                value: haptics,
                onChanged: (v) =>
                    ref.read(hapticsEnabledProvider.notifier).set(v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
