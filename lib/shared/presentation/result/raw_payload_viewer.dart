import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_snackbar.dart';

/// The full raw encoded value, collapsed by default and never the primary
/// content of a result (docs/design/design-system.md: "raw payloads as
/// primary content" is a thing to avoid). Selectable, and copyable via the
/// Flutter SDK's `Clipboard` — no new dependency.
class RawPayloadViewer extends StatefulWidget {
  const RawPayloadViewer({required this.payload, super.key});

  final String payload;

  @override
  State<RawPayloadViewer> createState() => _RawPayloadViewerState();
}

class _RawPayloadViewerState extends State<RawPayloadViewer> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: 'Raw payload',
          expanded: _expanded,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.tight),
              child: Row(
                children: [
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        'Raw payload',
                        style: AppTypography.cardTitle.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppSpacing.micro),
            padding: const EdgeInsets.all(AppSpacing.standard),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  widget.payload,
                  style: AppTypography.supportingText.copyWith(
                    color: colorScheme.onSurface,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: AppSpacing.tight),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.payload));
                      AppSnackbar.show(context, 'Copied to clipboard');
                    },
                    icon: const Icon(Icons.content_copy_outlined, size: 18),
                    label: const Text('Copy'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
