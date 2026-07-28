import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';

/// A titled group of rows rendered as a single bordered, grouped-list
/// container with dividers between rows — matching the section style in
/// docs/design/references/stitch_secure_url_scanner_ux/settings/code.html.
///
/// Settings uses this one grouping container per section rather than
/// wrapping each individual row in its own card, per
/// docs/design/design-system.md's "no excessive cards" guidance.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.tight,
            bottom: AppSpacing.tight,
          ),
          child: Text(
            title,
            style: AppTypography.compactLabel.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A single navigable or informational row within a [SettingsSection].
///
/// Set [onTap] for a row that navigates elsewhere (a trailing chevron is
/// shown automatically unless [trailing] overrides it). Omit it for a
/// purely informational row. Set [destructive] for actions like clearing
/// data.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleColor = destructive ? AppColors.critical : null;

    return ListTile(
      leading: Icon(icon, color: destructive ? AppColors.critical : null),
      title: Text(
        title,
        style: titleColor != null ? TextStyle(color: titleColor) : null,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant)
              : null),
      onTap: onTap,
    );
  }
}

/// A row for a preference that is genuinely always on (e.g. on-device
/// processing) — shown as a status, never a toggle, since there is nothing
/// for the user to change.
class SettingsStatusRow extends StatelessWidget {
  const SettingsStatusRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.tight,
          vertical: AppSpacing.micro,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          statusLabel,
          style: AppTypography.compactLabel.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

/// A local, session-only toggle row. Callers own the state; this widget is
/// purely presentational.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

/// An honestly-disabled row for a control that has no integration behind
/// it yet. Mirrors the Tooltip + Semantics(enabled: false) pattern used by
/// ScannerUnavailableState's retry action, so screen readers and pointer
/// users both get an accurate, non-interactive affordance.
class SettingsDisabledRow extends StatelessWidget {
  const SettingsDisabledRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.disabledReason,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String disabledReason;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final row = ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.unfold_more, color: colorScheme.onSurfaceVariant),
      enabled: false,
    );

    return Tooltip(
      message: disabledReason,
      child: Semantics(enabled: false, button: false, child: row),
    );
  }
}
