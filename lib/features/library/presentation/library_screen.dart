import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/fixtures/catalog/collection_fixtures.dart';
import '../../../shared/fixtures/models/library_item_fixture.dart';
import '../application/library_preview_controller.dart';
import '../application/relative_date.dart';
import 'widgets/collection_chip.dart';
import 'widgets/duplicate_scan_sheet.dart';
import 'widgets/library_filter_sheet.dart';
import 'widgets/scan_list_tile.dart';

/// Injectable preview-only display states for [LibraryScreen], matching the
/// pattern used by the Scanner feature in Milestone 002A: loading and error
/// are UI states demonstrated directly, not simulated with fake async work.
enum LibraryDisplayState { loading, error }

/// The Library home destination: a personal scan workspace (Pillar 4 in
/// docs/product/product-contract.md), not a plain history list — search,
/// filters, collections, favorites and a date-grouped list of saved scans.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({this.previewDisplayState, super.key});

  /// When set, renders a fixed loading/error preview instead of
  /// controller-driven content. Left null for normal use.
  final LibraryDisplayState? previewDisplayState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (previewDisplayState) {
      case LibraryDisplayState.loading:
        return const _LibraryLoadingScaffold();
      case LibraryDisplayState.error:
        return const _LibraryErrorScaffold();
      case null:
        break;
    }

    final state = ref.watch(libraryPreviewControllerProvider);
    final controller = ref.read(libraryPreviewControllerProvider.notifier);
    final visibleItems = state.visibleItems;
    final isTrueEmpty = state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            tooltip: 'Search your library',
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.librarySearch),
          ),
          IconButton(
            tooltip: 'Filter your library',
            icon: const Icon(Icons.tune),
            onPressed: () async {
              final result = await LibraryFilterSheet.show(
                context,
                initialSelection: state.filters,
              );
              if (result != null) controller.applyFilters(result);
            },
          ),
        ],
      ),
      body: isTrueEmpty
          ? _TrueEmptyState(onScan: () => context.go(AppRoutes.scan))
          : Column(
              children: [
                const SizedBox(height: AppSpacing.tight),
                _CollectionsRow(items: state.items),
                Expanded(
                  child: visibleItems.isEmpty
                      ? const _NoMatchesState()
                      : _GroupedScanList(
                          items: visibleItems,
                          onOpenItem: (item) => _openItem(context, item),
                          onToggleFavorite: controller.toggleFavorite,
                          onDelete: (item) =>
                              _confirmAndDelete(context, controller, item),
                        ),
                ),
              ],
            ),
    );
  }

  void _openItem(BuildContext context, LibraryItemFixture item) {
    if (item.isDuplicateExample) {
      DuplicateScanSheet.show(context, item: item);
    } else {
      context.push(AppRoutes.libraryScanDetail(item.id));
    }
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
    AppSnackbar.show(
      context,
      'Scan deleted',
      actionLabel: 'Undo',
      onAction: controller.undoDelete,
    );
  }
}

class _CollectionsRow extends StatelessWidget {
  const _CollectionsRow({required this.items});

  final List<LibraryItemFixture> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        itemCount: allCollectionFixtures.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.tight),
        itemBuilder: (context, index) {
          final collection = allCollectionFixtures[index];
          final count = items
              .where((item) => item.collectionId == collection.id)
              .length;
          return CollectionChip(
            label: collection.name,
            count: count,
            onTap: () =>
                context.push(AppRoutes.libraryCollectionDetail(collection.id)),
          );
        },
      ),
    );
  }
}

class _GroupedScanList extends StatelessWidget {
  const _GroupedScanList({
    required this.items,
    required this.onOpenItem,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final List<LibraryItemFixture> items;
  final ValueChanged<LibraryItemFixture> onOpenItem;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<LibraryItemFixture> onDelete;

  static const _groupOrder = ['Today', 'Yesterday', 'This week', 'Earlier'];

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<LibraryItemFixture>>{};
    for (final item in items) {
      final label = dateGroupLabel(item.savedAt, libraryPreviewNow);
      groups.putIfAbsent(label, () => []).add(item);
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.section),
      children: [
        for (final label in _groupOrder)
          if (groups[label] case final groupItems?) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.standard,
                AppSpacing.screen,
                AppSpacing.tight,
              ),
              child: Text(
                label,
                style: AppTypography.compactLabel.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final item in groupItems)
              ScanListTile(
                key: ValueKey(item.id),
                item: item,
                now: libraryPreviewNow,
                onTap: () => onOpenItem(item),
                onToggleFavorite: () => onToggleFavorite(item.id),
                onDelete: () => onDelete(item),
              ),
          ],
      ],
    );
  }
}

class _TrueEmptyState extends StatelessWidget {
  const _TrueEmptyState({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Nothing saved yet',
      message:
          'Your scanned QR codes and barcodes can be saved locally for '
          'quick access. Everything stays on your device.',
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: 'Scan a code',
            icon: Icons.qr_code_scanner,
            onPressed: onScan,
          ),
          const SizedBox(height: AppSpacing.tight),
          Tooltip(
            message:
                'Importing from your gallery will be available once '
                'gallery integration is connected.',
            child: Semantics(
              button: true,
              enabled: false,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Import from gallery'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMatchesState extends StatelessWidget {
  const _NoMatchesState();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.search_off,
      title: 'No matches',
      message: 'Try a different search term or adjust your filters.',
    );
  }
}

class _LibraryLoadingScaffold extends StatelessWidget {
  const _LibraryLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _LibraryErrorScaffold extends StatelessWidget {
  const _LibraryErrorScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: EmptyState(
        icon: Icons.error_outline,
        title: "Couldn't load your Library",
        message:
            'Something prevented your saved scans from loading. Please '
            'try again.',
        action: Tooltip(
          message:
              'Retrying will be available once Library persistence '
              'is added.',
          child: Semantics(
            button: true,
            enabled: false,
            child: PrimaryButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: null,
            ),
          ),
        ),
      ),
    );
  }
}
