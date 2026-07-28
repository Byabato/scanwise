import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../app/theme/theme_mode_provider.dart';
import 'settings_screen.dart' show themeModeLabel;

/// Theme preference: System / Light / Dark, presented as small preview
/// swatches per docs/design/references/.../settings/code.html's Appearance
/// section. Reuses the existing session-only [themeModeProvider] rather
/// than introducing new state — nothing here persists across a restart.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'Theme',
            style: AppTypography.sectionTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.standard),
          Row(
            children: [
              for (final mode in ThemeMode.values) ...[
                if (mode != ThemeMode.values.first)
                  const SizedBox(width: AppSpacing.standard),
                Expanded(
                  child: _ThemeSwatch(
                    mode: mode,
                    selected: mode == themeMode,
                    onTap: () =>
                        ref.read(themeModeProvider.notifier).select(mode),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          Text(
            'Resets when you restart the app.',
            style: AppTypography.supportingText.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = themeModeLabel(mode);

    return Semantics(
      button: true,
      selected: selected,
      label: '$label theme',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.all(AppSpacing.tight),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outline,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: SizedBox(height: 56, child: _Preview(mode: mode)),
              ),
              const SizedBox(height: AppSpacing.tight),
              Text(
                label,
                style: AppTypography.compactLabel.copyWith(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A miniature light/dark preview swatch. Colors come directly from
/// [AppColors] — the only tokens this preview is allowed to reference,
/// since it exists specifically to show those themes.
class _Preview extends StatelessWidget {
  const _Preview({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case ThemeMode.system:
        return const Column(
          children: [
            Expanded(child: ColoredBox(color: AppColors.lightSurface)),
            Expanded(child: ColoredBox(color: AppColors.darkSurface)),
          ],
        );
      case ThemeMode.light:
        return const ColoredBox(
          color: AppColors.lightSurface,
          child: Center(
            child: Icon(
              Icons.light_mode_outlined,
              color: AppColors.lightTextSecondary,
            ),
          ),
        );
      case ThemeMode.dark:
        return const ColoredBox(
          color: AppColors.darkSurface,
          child: Center(
            child: Icon(
              Icons.dark_mode_outlined,
              color: AppColors.darkTextSecondary,
            ),
          ),
        );
    }
  }
}
