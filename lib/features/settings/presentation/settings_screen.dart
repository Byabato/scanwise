import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../app/theme/theme_mode_provider.dart';
import 'widgets/settings_section.dart';

/// Settings home: a plain navigation list, sectioned to match
/// docs/design/references/.../settings/code.html's grouping (Privacy,
/// Scanning, History, Appearance, About). Every row navigates to a real
/// sub-screen — there is no "coming soon" placeholder left in this list.
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
          SettingsSection(
            title: 'Privacy',
            children: [
              SettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy and data',
                subtitle: 'Processing, incognito, and clearing history',
                onTap: () => context.push(AppRoutes.settingsPrivacy),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          SettingsSection(
            title: 'Scanning',
            children: [
              SettingsRow(
                icon: Icons.tune,
                title: 'Scanning preferences',
                subtitle: 'Haptics and external action confirmation',
                onTap: () => context.push(AppRoutes.settingsScanning),
              ),
              SettingsRow(
                icon: Icons.qr_code_2_outlined,
                title: 'Supported formats',
                subtitle: 'QR codes and barcodes ScanWise recognizes',
                onTap: () => context.push(AppRoutes.settingsFormats),
              ),
              SettingsRow(
                icon: Icons.camera_alt_outlined,
                title: 'Permissions',
                subtitle: 'Camera access',
                onTap: () => context.push(AppRoutes.settingsPermissions),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          SettingsSection(
            title: 'History',
            children: [
              SettingsRow(
                icon: Icons.history_outlined,
                title: 'History preferences',
                subtitle: 'Duplicate detection and saved scan details',
                onTap: () => context.push(AppRoutes.settingsHistory),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          SettingsSection(
            title: 'Appearance',
            children: [
              SettingsRow(
                icon: Icons.brightness_6_outlined,
                title: 'Theme',
                subtitle: themeModeLabel(themeMode),
                onTap: () => context.push(AppRoutes.settingsAppearance),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          SettingsSection(
            title: 'About',
            children: [
              SettingsRow(
                icon: Icons.info_outline,
                title: 'About ScanWise',
                subtitle: 'Version and legal',
                onTap: () => context.push(AppRoutes.settingsAbout),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared label for [ThemeMode], used by both the Settings home subtitle
/// and the Appearance screen so they stay in sync.
String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'System',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};
