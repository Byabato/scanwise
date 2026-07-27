import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/design_tokens.dart';
import '../../core/widgets/coming_soon_tag.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';

/// Foundation Library destination. Search and persistence are not
/// implemented yet, so this screen only shows the empty state and an honest,
/// non-interactive search affordance.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.standard),
            const _DisabledSearchBar(),
            Expanded(
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No scans yet',
                message:
                    'Scans you choose to save will appear here, organized '
                    'and searchable.',
                action: PrimaryButton(
                  label: 'Start scanning',
                  icon: Icons.qr_code_scanner,
                  onPressed: () => context.go(AppRoutes.scan),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisabledSearchBar extends StatelessWidget {
  const _DisabledSearchBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Search — available after Library persistence is added',
      child: Semantics(
        label: 'Search your library',
        hint: 'Available after Library persistence is added',
        enabled: false,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.tight),
              Expanded(
                child: Text(
                  'Search your library',
                  style: AppTypography.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const ComingSoonTag(),
            ],
          ),
        ),
      ),
    );
  }
}
