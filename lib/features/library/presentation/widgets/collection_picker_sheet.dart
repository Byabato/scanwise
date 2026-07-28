import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../../shared/fixtures/catalog/collection_fixtures.dart';
import '../../../../shared/fixtures/models/collection_fixture.dart';
import '../../../../shared/fixtures/models/result_fixture_kind.dart';
import 'create_collection_sheet.dart';

/// Modal picker for assigning a Library item to a collection.
///
/// Contract for the value returned by [show]: `null` means the sheet was
/// dismissed without a choice; the empty string `''` means "None" was
/// explicitly chosen (clear the collection); any other string is the
/// chosen collection's id. This distinguishes an explicit clear from a
/// no-op dismissal, which a plain nullable string can't do on its own.
class CollectionPickerSheet extends StatefulWidget {
  const CollectionPickerSheet({
    this.suggestedForKind,
    this.selectedCollectionId,
    super.key,
  });

  final ResultFixtureKind? suggestedForKind;
  final String? selectedCollectionId;

  static Future<String?> show(
    BuildContext context, {
    ResultFixtureKind? suggestedForKind,
    String? selectedCollectionId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (_) => CollectionPickerSheet(
        suggestedForKind: suggestedForKind,
        selectedCollectionId: selectedCollectionId,
      ),
    );
  }

  @override
  State<CollectionPickerSheet> createState() => _CollectionPickerSheetState();
}

class _CollectionPickerSheetState extends State<CollectionPickerSheet> {
  late List<CollectionFixture> _collections = List.of(allCollectionFixtures);

  Future<void> _createCollection() async {
    final created = await CreateCollectionSheet.show(context);
    if (created == null || !mounted) return;
    setState(() => _collections = [..._collections, created]);
    if (mounted) Navigator.of(context).pop(created.id);
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
            Text(
              'Choose a collection',
              style: AppTypography.sectionTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _CollectionRow(
                    icon: Icons.block,
                    title: 'None',
                    selected: widget.selectedCollectionId == null,
                    onTap: () => Navigator.of(context).pop(''),
                  ),
                  for (final collection in _collections)
                    _CollectionRow(
                      icon: Icons.folder_outlined,
                      title: collection.name,
                      subtitle: collection.description,
                      suggested:
                          widget.suggestedForKind != null &&
                          collection.suggestedForKinds.contains(
                            widget.suggestedForKind,
                          ),
                      selected: widget.selectedCollectionId == collection.id,
                      onTap: () => Navigator.of(context).pop(collection.id),
                    ),
                  _CollectionRow(
                    icon: Icons.add,
                    title: 'New collection',
                    onTap: _createCollection,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.suggested = false,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool suggested;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: suggested ? '$title, suggested' : title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.tight),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.compact),
                    Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
                    const SizedBox(width: AppSpacing.tight),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTypography.body.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: AppTypography.supportingText.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (suggested)
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
                          'Suggested',
                          style: AppTypography.compactLabel.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
