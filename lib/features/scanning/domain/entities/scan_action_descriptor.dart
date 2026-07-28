import '../enums/scan_action_type.dart';

/// A context-aware action a [ParsedScan] supports, independent of any
/// platform behavior.
///
/// This describes *intent*, not execution: nothing in the domain layer
/// opens a URL, places a call, or writes to the clipboard. Presentation
/// code (see `parsed_scan_presentation_mapper.dart`) turns a descriptor
/// into a concrete widget action, and application/infrastructure code
/// (a later milestone) supplies the actual platform behavior for
/// `enabled` actions.
class ScanActionDescriptor {
  const ScanActionDescriptor({
    required this.type,
    required this.label,
    required this.enabled,
    this.disabledReason,
    this.requiresConfirmation = false,
    this.copyValue,
    this.isSensitive = false,
    this.isPrimary = false,
  }) : assert(
         enabled || disabledReason != null,
         'Disabled actions must explain why via disabledReason.',
       ),
       assert(
         !isSensitive || copyValue != null,
         'Sensitive actions must carry the value they guard (e.g. a '
         'Wi-Fi password) so presentation can mask it — see WifiPayload.',
       );

  final ScanActionType type;

  /// Human-facing label, already specific to context (e.g. "Copy
  /// password" vs. "Copy link") — the domain composes this because it
  /// alone knows which field a generic action type applies to.
  final String label;

  /// False when the action needs an integration excluded from this
  /// milestone (mobile_scanner, url_launcher, share_plus, Drift, contact
  /// or calendar platform APIs — see AGENTS.md).
  final bool enabled;

  /// User-facing explanation shown when [enabled] is false.
  final String? disabledReason;

  /// True when the product contract requires explicit confirmation before
  /// this action proceeds (e.g. opening a URL, or sharing a Wi-Fi result
  /// that may expose a password) — see docs/product/user-flows.md.
  final bool requiresConfirmation;

  /// The value a `copy`-type action copies. Also used by `share`/`save`
  /// mappings that need the same underlying value.
  final String? copyValue;

  /// True when [copyValue] is sensitive (currently: a Wi-Fi password) and
  /// should stay masked until the user explicitly reveals it.
  final bool isSensitive;

  /// At most one descriptor per [ParsedScan] should be primary, per the
  /// product contract's "one main action" principle. [resolveScanActions]
  /// enforces this.
  final bool isPrimary;
}
