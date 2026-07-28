import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../shared/fixtures/catalog/collection_fixtures.dart';
import '../../../shared/fixtures/models/library_item_fixture.dart';
import '../../../shared/presentation/result/scan_result_view.dart';
import '../application/library_preview_controller.dart';
import 'widgets/collection_picker_sheet.dart';
import 'widgets/edit_note_sheet.dart';

/// A saved scan's detail screen: the shared [ScanResultView] hierarchy plus
/// Library-specific chrome (source/collection info, notes, delete) per the
/// `scan_detail` Stitch reference.
class ScanDetailScreen extends ConsumerWidget {
  const ScanDetailScreen({required this.scanId, super.key});

  final String scanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryPreviewControllerProvider);
    final controller = ref.read(libraryPreviewControllerProvider.notifier);

    LibraryItemFixture? item;
    for (final candidate in state.items) {
      if (candidate.id == scanId) {
        item = candidate;
        break;
      }
    }

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan detail')),
        body: const Center(child: Text('Scan not found')),
      );
    }

    final found = item;
    final collection = _collectionNameFor(found.collectionId);
    final source = _sourceFor(found);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan detail'),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => AppSnackbar.show(
              context,
              'Sharing will be available once share actions are connected.',
            ),
          ),
          IconButton(
            tooltip: 'Edit note',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editNote(context, controller, found),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScanResultView(fixture: found.result),
            const SizedBox(height: AppSpacing.section),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.source_outlined,
                    label: 'Source',
                    value: source,
                  ),
                ),
                const SizedBox(width: AppSpacing.tight),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.folder_outlined,
                    label: 'Collection',
                    value: collection ?? 'None',
                    onTap: () => _changeCollection(context, controller, found),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.standard),
            _NotesCard(
              note: found.note,
              onTap: () => _editNote(context, controller, found),
            ),
            const SizedBox(height: AppSpacing.section),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.tight),
            Center(
              child: TextButton.icon(
                onPressed: () => _confirmAndDelete(context, controller, found),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.critical,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete scan'),
              ),
            ),
            Text(
              'This will permanently remove this scan from your Library.',
              textAlign: TextAlign.center,
              style: AppTypography.supportingText.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _collectionNameFor(String? collectionId) {
    if (collectionId == null) return null;
    for (final collection in allCollectionFixtures) {
      if (collection.id == collectionId) return collection.name;
    }
    return null;
  }

  String _sourceFor(LibraryItemFixture item) {
    for (final field in item.result.technicalDetails) {
      if (field.label == 'Scan source') return field.value;
    }
    return 'Camera';
  }

  Future<void> _editNote(
    BuildContext context,
    LibraryPreviewController controller,
    LibraryItemFixture item,
  ) async {
    final result = await EditNoteSheet.show(context, initialNote: item.note);
    if (result == null || !context.mounted) return;
    controller.updateNote(item.id, result.isEmpty ? null : result);
  }

  Future<void> _changeCollection(
    BuildContext context,
    LibraryPreviewController controller,
    LibraryItemFixture item,
  ) async {
    final result = await CollectionPickerSheet.show(
      context,
      suggestedForKind: item.result.kind,
      selectedCollectionId: item.collectionId,
    );
    if (result == null || !context.mounted) return;
    controller.assignCollection(item.id, result.isEmpty ? null : result);
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    LibraryPreviewController controller,
    LibraryItemFixture item,
  ) async {
    final confirmed = await ConfirmationSheet.show(
      context,
      title: 'Delete this scan?',
      message:
          '"${item.result.title}" will be removed from your Library. You '
          'can undo this right after.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    controller.deleteItem(item.id);
    if (context.mounted) {
      context.pop();
    }
    if (context.mounted) {
      AppSnackbar.show(
        context,
        'Scan deleted',
        actionLabel: 'Undo',
        onAction: controller.undoDelete,
      );
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.standard),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(height: AppSpacing.tight),
          Text(
            label,
            style: AppTypography.compactLabel.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.body.copyWith(color: colorScheme.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Semantics(
      button: true,
      label: '$label: $value. Double tap to change.',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ExcludeSemantics(child: content),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.note, required this.onTap});

  final String? note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasNote = note != null && note!.isNotEmpty;

    return Semantics(
      button: true,
      label: hasNote ? 'Note: $note' : 'Add a note',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ExcludeSemantics(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.standard),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: AppTypography.compactLabel.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.micro),
                Text(
                  hasNote ? note! : 'Add a note to remember why this matters.',
                  style: AppTypography.body.copyWith(
                    color: hasNote
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
