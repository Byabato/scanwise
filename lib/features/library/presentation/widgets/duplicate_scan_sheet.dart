import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/fixtures/catalog/collection_fixtures.dart';
import '../../../../shared/fixtures/models/collection_fixture.dart';
import '../../../../shared/fixtures/models/library_item_fixture.dart';
import '../../application/library_preview_controller.dart';
import '../../application/relative_date.dart';

/// Presents Signature 5 ("Duplicate Intelligence") from
/// docs/product/product-contract.md: rather than rejecting a duplicate
/// scan, shows its previous context and lets the user decide what to do
/// next.
class DuplicateScanSheet extends ConsumerWidget {
  const DuplicateScanSheet({required this.item, super.key});

  final LibraryItemFixture item;

  static Future<void> show(
    BuildContext context, {
    required LibraryItemFixture item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (_) => DuplicateScanSheet(item: item),
    );
  }

  CollectionFixture? _collectionFor(String? id) {
    if (id == null) return null;
    for (final collection in allCollectionFixtures) {
      if (collection.id == id) return collection;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = ref.read(libraryPreviewControllerProvider.notifier);
    final collection = _collectionFor(item.collectionId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.standard,
          AppSpacing.screen,
          AppSpacing.standard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.section),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.compact,
                vertical: AppSpacing.micro,
              ),
              decoration: BoxDecoration(
                color: AppColors.caution.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 16, color: AppColors.caution),
                  const SizedBox(width: AppSpacing.micro),
                  Text(
                    'Duplicate found',
                    style: AppTypography.compactLabel.copyWith(
                      color: AppColors.caution,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            Text(
              'You scanned this before',
              style: AppTypography.sectionTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.micro),
            Text(
              'This item already exists in your Library.',
              style: AppTypography.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            Container(
              padding: const EdgeInsets.all(AppSpacing.standard),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.result.title,
                    style: AppTypography.cardTitle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.tight),
                  _InfoRow(
                    icon: Icons.event_outlined,
                    label:
                        'Last saved: '
                        '${formatRelativeDate(item.savedAt, libraryPreviewNow)}',
                  ),
                  const SizedBox(height: AppSpacing.micro),
                  _InfoRow(
                    icon: Icons.folder_outlined,
                    label: 'Collection: ${collection?.name ?? 'None'}',
                  ),
                  const SizedBox(height: AppSpacing.micro),
                  _InfoRow(
                    icon: Icons.repeat,
                    label: 'Scanned ${item.occurrenceCount} times',
                  ),
                  if (item.note != null) ...[
                    const SizedBox(height: AppSpacing.micro),
                    _InfoRow(icon: Icons.notes_outlined, label: item.note!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.libraryScanDetail(item.id));
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open existing record'),
            ),
            const SizedBox(height: AppSpacing.tight),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.recordOccurrence(item.id);
                      Navigator.of(context).pop();
                      AppSnackbar.show(
                        context,
                        'Recorded a new occurrence — now scanned '
                        '${item.occurrenceCount + 1} times.',
                      );
                    },
                    icon: const Icon(Icons.update),
                    label: const Text('Record new occurrence'),
                  ),
                ),
                const SizedBox(width: AppSpacing.tight),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AppSnackbar.show(
                        context,
                        'Saving separately will be available once Library '
                        'persistence is added.',
                      );
                    },
                    icon: const Icon(Icons.content_copy_outlined),
                    label: const Text('Save separately'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.tight),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.tight),
        Expanded(
          child: Text(
            label,
            style: AppTypography.supportingText.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
