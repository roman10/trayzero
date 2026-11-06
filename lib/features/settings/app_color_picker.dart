import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/appearance_preferences.dart';
import '../../l10n/gen/app_localizations.dart';

String paletteLabel(AppLocalizations l10n, AppPalette palette) =>
    switch (palette) {
      AppPalette.amber => l10n.paletteAmber,
      AppPalette.blue => l10n.paletteBlue,
      AppPalette.cyan => l10n.paletteCyan,
      AppPalette.teal => l10n.paletteTeal,
      AppPalette.green => l10n.paletteGreen,
      AppPalette.violet => l10n.paletteViolet,
      AppPalette.rose => l10n.paletteRose,
    };

/// The grid of palette swatches (keys `palette_<id>` / `palette_semantics_<id>`),
/// used by the Appearance screen.
class PaletteOptions extends StatelessWidget {
  const PaletteOptions({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final AppPalette selected;
  final ValueChanged<AppPalette> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final palette = selected;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final option in AppPalette.values)
              SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: Semantics(
                  key: ValueKey('palette_semantics_${option.id}'),
                  container: true,
                  excludeSemantics: true,
                  button: true,
                  selected: option == palette,
                  label: paletteLabel(l10n, option),
                  onTap: () => onSelect(option),
                  child: OutlinedButton(
                    key: ValueKey('palette_${option.id}'),
                    onPressed: () => onSelect(option),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 64),
                      padding: const EdgeInsets.all(12),
                      foregroundColor: scheme.onSurface,
                      side: BorderSide(
                        color: option == palette
                            ? scheme.primary
                            : scheme.outlineVariant,
                        width: option == palette ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorScheme.fromSeed(
                              seedColor: option.seed,
                              brightness: brightness,
                            ).primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(paletteLabel(l10n, option))),
                        if (option == palette) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
