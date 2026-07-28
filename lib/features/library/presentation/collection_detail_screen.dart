import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../shared/fixtures/catalog/collection_fixtures.dart';
import '../../../shared/fixtures/models/collection_fixture.dart';
import '../../../shared/fixtures/models/library_item_fixture.dart';
import '../application/library_preview_controller.dart';
import 'widgets/duplicate_scan_sheet.dart';
import 'widgets/scan_list_tile.dart';

/// A single collection's contents: header (name, description, live item
/// count), a search field scoped to this collection, and its scans — per
/// the `collection_detail` Stitch reference's structure, adapted from its
/// "contacts" framing to generic scan items.
class CollectionDetailScreen extends ConsumerStatefulWidget {
  const CollectionDetailScreen({required this.collectionId, super.key});

  final String collectionId;

  @override
  ConsumerState<CollectionDetailScreen> createState() =>
      _CollectionDetailScreenState();
}

class _CollectionDetailScreenState
    extends ConsumerState<CollectionDetailScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CollectionFixture? get _collection {
    for (final collection in allCollectionFixtures) {
      if (collection.id == widget.collectionId) return collection;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final collection = _collection;
    if (collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection')),
        body: const Center(child: Text('Collection not found')),
      );
    }

    final state = ref.watch(libraryPreviewControllerProvider);
    final controller = ref.read(libraryPreviewControllerProvider.notifier);

    final allInCollection = state.items
        .where((item) => item.collectionId == widget.collectionId)
        .toList();
    final query = _query.trim().toLowerCase();
    final visible =
        (query.isEmpty
              ? allInCollection
              : allInCollection.where((item) {
                  final haystack = [
                    item.result.title,
                    if (item.result.subtitle != null) item.result.subtitle!,
                    if (item.note != null) item.note!,
                  ].join(' ').toLowerCase();
                  return haystack.contains(query);
                }).toList())
          ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

    return Scaffold(
      appBar: AppBar(title: Text(collection.name)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.standard),
            _CollectionHeaderCard(
              collection: collection,
              itemCount: allInCollection.length,
            ),
            const SizedBox(height: AppSpacing.standard),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in ${collection.name}',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.tight),
            Expanded(
              child: visible.isEmpty
                  ? EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: allInCollection.isEmpty
                          ? 'No scans in this collection yet'
                          : 'No matches',
                      message: allInCollection.isEmpty
                          ? 'Scans you assign to ${collection.name} will '
                                'appear here.'
                          : 'Try a different search term.',
                    )
                  : ListView.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final item = visible[index];
                        return ScanListTile(
                          key: ValueKey(item.id),
                          item: item,
                          now: libraryPreviewNow,
                          onTap: () => _openItem(context, item),
                          onToggleFavorite: () =>
                              controller.toggleFavorite(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
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
}

class _CollectionHeaderCard extends StatelessWidget {
  const _CollectionHeaderCard({
    required this.collection,
    required this.itemCount,
  });

  final CollectionFixture collection;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.standard),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.tight,
              vertical: AppSpacing.micro,
            ),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Text(
              '$itemCount ${itemCount == 1 ? 'scan' : 'scans'}',
              style: AppTypography.compactLabel.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.tight),
          Text(
            collection.name,
            style: AppTypography.cardTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          if (collection.description != null) ...[
            const SizedBox(height: AppSpacing.micro),
            Text(
              collection.description!,
              style: AppTypography.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
