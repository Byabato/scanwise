import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../../shared/fixtures/models/library_item_fixture.dart';
import '../../../../shared/fixtures/models/result_fixture_kind.dart';
import '../../application/relative_date.dart';

/// One row in a Library list: kind icon, title, subtitle (kind + relative
/// saved date, or a note preview when present), a favorite toggle and a
/// compact kind chip. Reused by the main Library list, search results and
/// collection detail.
class ScanListTile extends StatelessWidget {
  const ScanListTile({
    required this.item,
    required this.now,
    required this.onTap,
    required this.onToggleFavorite,
    this.onDelete,
    super.key,
  });

  final LibraryItemFixture item;

  /// The fixed reference "now" used for relative-date copy — always
  /// `libraryPreviewNow` in this milestone.
  final DateTime now;

  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  /// When non-null, a delete affordance is shown. Only the primary Library
  /// list wires this — search and collection detail leave it null and rely
  /// on scan detail's danger zone instead.
  final VoidCallback? onDelete;

  static IconData iconFor(ResultFixtureKind kind) {
    switch (kind) {
      case ResultFixtureKind.trustedUrl:
      case ResultFixtureKind.suspiciousUrl:
        return Icons.link;
      case ResultFixtureKind.wifi:
        return Icons.wifi;
      case ResultFixtureKind.contact:
        return Icons.badge_outlined;
      case ResultFixtureKind.product:
        return Icons.qr_code_2_outlined;
      case ResultFixtureKind.calendarEvent:
        return Icons.event_outlined;
      case ResultFixtureKind.phone:
        return Icons.call_outlined;
      case ResultFixtureKind.email:
        return Icons.mail_outline;
      case ResultFixtureKind.sms:
        return Icons.sms_outlined;
      case ResultFixtureKind.location:
        return Icons.place_outlined;
      case ResultFixtureKind.plainText:
        return Icons.notes_outlined;
      case ResultFixtureKind.unsupported:
        return Icons.help_outline;
    }
  }

  /// Short, compact-label-style badge text for the trailing kind chip — an
  /// intentional exception to sentence case, matching the design system's
  /// allowance for compact technical labels (e.g. "EAN-13").
  static String shortLabelFor(ResultFixtureKind kind) {
    switch (kind) {
      case ResultFixtureKind.trustedUrl:
      case ResultFixtureKind.suspiciousUrl:
        return 'LINK';
      case ResultFixtureKind.wifi:
        return 'WI-FI';
      case ResultFixtureKind.contact:
        return 'CONTACT';
      case ResultFixtureKind.product:
        return 'PRODUCT';
      case ResultFixtureKind.calendarEvent:
        return 'EVENT';
      case ResultFixtureKind.phone:
        return 'PHONE';
      case ResultFixtureKind.email:
        return 'EMAIL';
      case ResultFixtureKind.sms:
        return 'SMS';
      case ResultFixtureKind.location:
        return 'PLACE';
      case ResultFixtureKind.plainText:
        return 'TEXT';
      case ResultFixtureKind.unsupported:
        return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = (item.note?.isNotEmpty ?? false)
        ? item.note!
        : '${item.result.typeLabel} · ${formatRelativeDate(item.savedAt, now)}';

    final semanticLabelBuffer = StringBuffer(item.result.title)
      ..write('. ')
      ..write(item.result.typeLabel);
    if (item.isFavorite) semanticLabelBuffer.write('. Favorite');
    if (item.isDuplicateExample) semanticLabelBuffer.write('. Scanned again');

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard,
          vertical: AppSpacing.micro,
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                label: semanticLabelBuffer.toString(),
                button: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: ExcludeSemantics(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.tight,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.button,
                                ),
                              ),
                              child: Icon(
                                iconFor(item.result.kind),
                                color: colorScheme.onSecondaryContainer,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.compact),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.result.title,
                                    style: AppTypography.cardTitle.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: AppTypography.supportingText
                                        .copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.isDuplicateExample) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Scanned again',
                                      style: AppTypography.compactLabel
                                          .copyWith(color: AppColors.caution),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.tight),
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.tight,
                  vertical: AppSpacing.micro,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  shortLabelFor(item.result.kind),
                  style: AppTypography.compactLabel.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: item.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              icon: Icon(
                item.isFavorite ? Icons.star : Icons.star_border,
                color: item.isFavorite
                    ? AppColors.caution
                    : colorScheme.onSurfaceVariant,
              ),
              onPressed: onToggleFavorite,
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete scan',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
