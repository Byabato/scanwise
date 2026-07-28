import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../../shared/fixtures/models/collection_fixture.dart';

/// Ephemeral "new collection" form. Returns the created [CollectionFixture]
/// via `Navigator.pop` — the caller is responsible for holding it in a
/// local, session-only list, since the static `allCollectionFixtures`
/// catalog is a shared const list that must not be mutated.
class CreateCollectionSheet extends StatefulWidget {
  const CreateCollectionSheet({super.key});

  static Future<CollectionFixture?> show(BuildContext context) {
    return showModalBottomSheet<CollectionFixture>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (_) => const CreateCollectionSheet(),
    );
  }

  @override
  State<CreateCollectionSheet> createState() => _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends State<CreateCollectionSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final collection = CollectionFixture(
      // Session-only identifier — never persisted, so a timestamp is a
      // sufficient uniqueness source here.
      id: 'collection-local-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description.isEmpty ? null : description,
    );
    Navigator.of(context).pop(collection);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screen,
          right: AppSpacing.screen,
          top: AppSpacing.standard,
          bottom:
              AppSpacing.standard + MediaQuery.of(context).viewInsets.bottom,
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
              'New collection',
              style: AppTypography.sectionTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.tight),
            Text(
              'This collection lasts for this session only — Milestone 003 '
              'adds real, persisted collections.',
              style: AppTypography.supportingText.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            FilledButton(
              onPressed: _canSave ? _save : null,
              child: const Text('Save'),
            ),
            const SizedBox(height: AppSpacing.tight),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
