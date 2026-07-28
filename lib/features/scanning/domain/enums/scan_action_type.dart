/// The semantic intent of a [ScanActionDescriptor], independent of label
/// text or icon. Presentation decides icon/tier; the domain only decides
/// which intents apply to a given [ScanKind] and whether each is currently
/// enabled — see `scan_action_resolver.dart`.
enum ScanActionType {
  open,
  call,
  composeEmail,
  composeSms,
  openLocation,
  addCalendarEvent,
  addContact,
  openWifiSettings,
  searchProduct,
  copy,
  share,
  save,

  /// Reserved for a future Library-integrated result surface. Not emitted
  /// by [resolveScanActions] in this milestone — annotating notes is
  /// user-editable Library metadata, not a scan-result action (see
  /// `ParsedScan`'s doc comment on that boundary).
  addNote,
}
