import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/coming_soon_tag.dart';
import 'widgets/settings_section.dart';

/// App identity, version, and legal links. Terms of Service and Privacy
/// Policy are honestly not wired up (no url_launcher use is permitted in
/// this milestone), so they carry a "Coming soon" tag rather than silently
/// doing nothing when tapped.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.standard,
        ),
        children: [
          const SettingsSection(
            title: 'ScanWise',
            children: [
              SettingsRow(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: 'Version 1.0.0',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const SettingsSection(
            title: 'Legal',
            children: [
              SettingsRow(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                trailing: ComingSoonTag(),
              ),
              SettingsRow(
                icon: Icons.policy_outlined,
                title: 'Privacy Policy',
                trailing: ComingSoonTag(),
              ),
            ],
          ),
          // Only registered/visible in debug builds — see
          // app/router/app_router.dart, which gates the debugGallery route
          // itself behind kDebugMode. In a release build this whole
          // section is omitted, so there is no way to reach it.
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.section),
            SettingsSection(
              title: 'Developer',
              children: [
                SettingsRow(
                  icon: Icons.bug_report_outlined,
                  title: 'Component gallery (debug)',
                  onTap: () => context.push(AppRoutes.debugGallery),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
