import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/library_preview_controller.dart';
import 'widgets/duplicate_scan_sheet.dart';
import 'widgets/scan_list_tile.dart';

/// Focused Library search: an autofocused field wired directly to
/// [LibraryPreviewController.setSearchQuery], sharing the same provider as
/// the main Library list so results and any deletions stay in sync.
///
/// The query is intentionally left in place after leaving this screen
/// (rather than cleared in `dispose`) — mutating provider state from a
/// widget's `dispose()` races with Riverpod/Flutter tearing down that same
/// widget's element and is unsafe. The main Library list still works
/// correctly either way; it just may already be search-filtered if the
/// user returns to it right after searching.
class LibrarySearchScreen extends ConsumerStatefulWidget {
  const LibrarySearchScreen({super.key});

  @override
  ConsumerState<LibrarySearchScreen> createState() =>
      _LibrarySearchScreenState();
}

class _LibrarySearchScreenState extends ConsumerState<LibrarySearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryPreviewControllerProvider);
    final controller = ref.read(libraryPreviewControllerProvider.notifier);
    final results = state.visibleItems;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search saved scans…',
            border: InputBorder.none,
          ),
          onChanged: controller.setSearchQuery,
        ),
      ),
      body: state.searchQuery.trim().isEmpty
          ? const _SearchPrompt()
          : results.isEmpty
          ? const EmptyState(
              icon: Icons.search_off,
              title: 'No matches',
              message: 'Try a different search term.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: AppSpacing.tight),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                return ScanListTile(
                  key: ValueKey(item.id),
                  item: item,
                  now: libraryPreviewNow,
                  onTap: () {
                    if (item.isDuplicateExample) {
                      DuplicateScanSheet.show(context, item: item);
                    } else {
                      context.push(AppRoutes.libraryScanDetail(item.id));
                    }
                  },
                  onToggleFavorite: () => controller.toggleFavorite(item.id),
                );
              },
            ),
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.search,
      title: 'Search your Library',
      message: 'Search by title or note.',
    );
  }
}
