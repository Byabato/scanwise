/// The authoritative classification of a parsed scan's content.
///
/// This is the domain counterpart to the Milestone 002
/// `ResultFixtureKind` — see `parsed_scan_presentation_mapper.dart` for how
/// the two are reconciled (they are not 1:1; see that file's documented
/// `product`/`isbn` mapping decision).
enum ScanKind {
  url,
  wifi,
  contact,
  email,
  phone,
  sms,
  location,
  calendarEvent,
  product,
  isbn,
  plainText,
  unknown,
}
