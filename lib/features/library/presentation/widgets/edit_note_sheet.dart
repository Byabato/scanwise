import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';

/// Add/edit-note bottom sheet for a Library item.
///
/// Contract for the value returned by [show] (and by popping this widget
/// directly): `null` means "no change" (Cancel, or dismissing the sheet);
/// a non-null string means Save was pressed, where an empty string means
/// the note was cleared. Callers should only invoke
/// `LibraryPreviewController.updateNote` when the result is non-null, and
/// pass `null` through to it when that string is empty.
class EditNoteSheet extends StatefulWidget {
  const EditNoteSheet({this.initialNote, super.key});

  final String? initialNote;

  static Future<String?> show(BuildContext context, {String? initialNote}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (_) => EditNoteSheet(initialNote: initialNote),
    );
  }

  @override
  State<EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends State<EditNoteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              widget.initialNote == null ? 'Add note' : 'Edit note',
              style: AppTypography.sectionTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'What do you want to remember about this scan?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_controller.text.trim()),
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
