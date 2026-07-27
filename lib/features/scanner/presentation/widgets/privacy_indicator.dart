import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';

/// Small pill reminding the user scan contents are processed on-device,
/// shown over the camera surface per docs/product/product-contract.md's
/// privacy statement.
class PrivacyIndicator extends StatelessWidget {
  const PrivacyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Scan contents are processed on this device',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.compact,
          vertical: AppSpacing.micro,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: AppColors.scannerForeground,
            ),
            const SizedBox(width: AppSpacing.micro),
            Flexible(
              child: Text(
                'Processed on this device',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.compactLabel.copyWith(
                  color: AppColors.scannerForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
