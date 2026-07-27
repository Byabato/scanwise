import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/design_tokens.dart';
import '../../app/theme/theme_mode_provider.dart';
import '../../core/widgets/coming_soon_tag.dart';

/// Foundation Settings destination. Only the theme preference is functional
/// in this milestone (session-only, not persisted). Every other row is
/// visibly marked as not yet available rather than silently doing nothing.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.standard,
        ),
        children: [
          const _SettingsSection(
            title: 'Privacy',
            children: [
              _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: 'How ScanWise handles your scans',
                subtitle:
                    'Scan contents are processed on your device and are '
                    'not uploaded by ScanWise.',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsRow(
                icon: Icons.brightness_6_outlined,
                title: 'Theme',
                subtitle: _themeModeLabel(themeMode),
                onTap: () => _showThemeSheet(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const _SettingsSection(
            title: 'Scanning',
            children: [
              _SettingsRow(
                icon: Icons.qr_code_2_outlined,
                title: 'Supported formats',
                available: false,
              ),
              _SettingsRow(
                icon: Icons.camera_alt_outlined,
                title: 'Permission management',
                available: false,
              ),
              _SettingsRow(
                icon: Icons.delete_outline,
                title: 'Clear data',
                available: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const _SettingsSection(
            title: 'About',
            children: [
              _SettingsRow(
                icon: Icons.info_outline,
                title: 'ScanWise',
                subtitle: 'Version 1.0.0 (foundation milestone)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  static void _showThemeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final selected = sheetRef.watch(themeModeProvider);

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.tight),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screen,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Theme',
                        style: AppTypography.sectionTitle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  RadioGroup<ThemeMode>(
                    groupValue: selected,
                    onChanged: (value) {
                      if (value != null) {
                        sheetRef.read(themeModeProvider.notifier).select(value);
                      }
                    },
                    child: Column(
                      children: [
                        for (final mode in ThemeMode.values)
                          RadioListTile<ThemeMode>(
                            value: mode,
                            title: Text(_themeModeLabel(mode)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.tight),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.tight,
            bottom: AppSpacing.tight,
          ),
          child: Text(
            title,
            style: AppTypography.compactLabel.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.available = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final isInteractive = available && onTap != null;

    final row = ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: !available
          ? const ComingSoonTag()
          : (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: isInteractive ? onTap : null,
      enabled: isInteractive,
    );

    if (available) return row;

    return Tooltip(
      message: '$title — coming soon',
      child: Semantics(enabled: false, button: false, child: row),
    );
  }
}
