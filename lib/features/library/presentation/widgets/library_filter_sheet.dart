import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../../shared/fixtures/catalog/collection_fixtures.dart';
import '../../../../shared/fixtures/models/result_fixture_kind.dart';
import '../../application/library_filter_selection.dart';

/// Human, sentence-case label for a [ResultFixtureKind] filter chip.
/// Distinct from `ScanListTile.shortLabelFor`, which is an intentionally
/// compact/uppercase badge — filter chips follow ordinary sentence case.
String _kindFilterLabel(ResultFixtureKind kind) {
  switch (kind) {
    case ResultFixtureKind.trustedUrl:
      return 'Trusted link';
    case ResultFixtureKind.suspiciousUrl:
      return 'Suspicious link';
    case ResultFixtureKind.wifi:
      return 'Wi-Fi';
    case ResultFixtureKind.contact:
      return 'Contact';
    case ResultFixtureKind.product:
      return 'Product';
    case ResultFixtureKind.calendarEvent:
      return 'Calendar event';
    case ResultFixtureKind.phone:
      return 'Phone';
    case ResultFixtureKind.email:
      return 'Email';
    case ResultFixtureKind.sms:
      return 'Text message';
    case ResultFixtureKind.location:
      return 'Location';
    case ResultFixtureKind.plainText:
      return 'Plain text';
    case ResultFixtureKind.unsupported:
      return 'Unsupported';
  }
}

/// Modal filter sheet: favorites-only toggle, a kind-chip type filter and a
/// single-select collection filter. Returns the new [LibraryFilterSelection]
/// via `Navigator.pop` — the caller applies it through
/// `LibraryPreviewController.applyFilters`.
class LibraryFilterSheet extends StatefulWidget {
  const LibraryFilterSheet({required this.initialSelection, super.key});

  final LibraryFilterSelection initialSelection;

  static Future<LibraryFilterSelection?> show(
    BuildContext context, {
    required LibraryFilterSelection initialSelection,
  }) {
    return showModalBottomSheet<LibraryFilterSelection>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (_) => LibraryFilterSheet(initialSelection: initialSelection),
    );
  }

  @override
  State<LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<LibraryFilterSheet> {
  late bool _favoritesOnly = widget.initialSelection.favoritesOnly;
  late Set<ResultFixtureKind> _kinds = Set.of(widget.initialSelection.kinds);
  late String? _collectionId = widget.initialSelection.collectionId;

  void _reset() {
    setState(() {
      _favoritesOnly = false;
      _kinds = {};
      _collectionId = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      LibraryFilterSelection(
        favoritesOnly: _favoritesOnly,
        kinds: _kinds,
        collectionId: _collectionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.standard,
          AppSpacing.screen,
          AppSpacing.standard,
        ),
        child: SingleChildScrollView(
          child: Column(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: AppTypography.sectionTitle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.tight),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Favorites only'),
                value: _favoritesOnly,
                onChanged: (value) => setState(() => _favoritesOnly = value),
              ),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.standard),
              Text(
                'Type',
                style: AppTypography.compactLabel.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.tight),
              Wrap(
                spacing: AppSpacing.tight,
                runSpacing: AppSpacing.tight,
                children: [
                  for (final kind in ResultFixtureKind.values)
                    FilterChip(
                      label: Text(_kindFilterLabel(kind)),
                      selected: _kinds.contains(kind),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _kinds = {..._kinds, kind};
                        } else {
                          _kinds = {..._kinds}..remove(kind);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.standard),
              Text(
                'Collection',
                style: AppTypography.compactLabel.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.tight),
              for (final collection in allCollectionFixtures)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(collection.name),
                  value: _collectionId == collection.id,
                  onChanged: (selected) => setState(() {
                    _collectionId = (selected ?? false) ? collection.id : null;
                  }),
                ),
              const SizedBox(height: AppSpacing.section),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.tight),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
