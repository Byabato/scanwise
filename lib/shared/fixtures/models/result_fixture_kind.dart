/// Temporary fixture/presentation model for Milestone 002 static UI. Not an
/// authoritative domain contract — Milestone 003 defines parsing,
/// normalization, duplicate identity and persistence models separately.
enum ResultFixtureKind {
  trustedUrl,
  suspiciousUrl,
  wifi,
  contact,
  product,
  calendarEvent,
  phone,
  email,
  sms,
  location,
  plainText,
  unsupported,
}
