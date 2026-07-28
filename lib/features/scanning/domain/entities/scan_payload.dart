import '../enums/barcode_symbology.dart';
import '../enums/isbn_format.dart';
import '../enums/wifi_security_type.dart';

/// The structured, typed interpretation of a scan's content.
///
/// One sealed hierarchy per docs/plans/003-domain-and-parsing.md, deliberately
/// replacing a single `Map<String, String>` — every scan kind exposes only
/// the fields that are actually meaningful for it, so callers get
/// compile-time exhaustiveness (`switch` on [ScanPayload]) instead of
/// stringly-typed lookups.
sealed class ScanPayload {
  const ScanPayload();
}

/// A recognized `http`/`https` URL. Every structural field a Milestone 004
/// risk assessment needs is exposed directly rather than re-parsed from
/// [rawUrl] — see docs/engineering/parsing-strategy.md.
final class UrlPayload extends ScanPayload {
  const UrlPayload({
    required this.rawUrl,
    required this.uri,
    required this.scheme,
    required this.host,
    required this.port,
    required this.path,
    required this.query,
    required this.fragment,
    required this.hasUserInfo,
  });

  final String rawUrl;
  final Uri uri;
  final String scheme;
  final String? host;

  /// Only set when the URL specifies an explicit, non-default port —
  /// null for e.g. `https://example.com` but 8080 for
  /// `https://example.com:8080`. Kept this way so "unusual port" can be a
  /// simple null-check in Milestone 004, not a default-port comparison
  /// re-derived from `uri.port`.
  final int? port;

  final String path;
  final String query;
  final String fragment;

  /// True when the URL embeds credentials (`user:pass@host`) — a
  /// structural risk signal, not a claim about validity.
  final bool hasUserInfo;
}

/// A `WIFI:` QR payload.
final class WifiPayload extends ScanPayload {
  const WifiPayload({
    required this.ssid,
    required this.securityType,
    required this.securityRaw,
    required this.hasPassword,
    required this.password,
    required this.isHidden,
  });

  final String ssid;
  final WifiSecurityType securityType;

  /// The original `T:` value verbatim (e.g. `WPA2-EAP`), preserved even
  /// when [securityType] is [WifiSecurityType.unknown] so the UI can still
  /// show something specific.
  final String securityRaw;

  final bool hasPassword;

  /// Never logged, never included in [ContentIdentity] — see
  /// docs/engineering/normalization-and-identity.md.
  final String? password;

  final bool isHidden;
}

/// A vCard 3.0/4.0 contact. Fields degrade to null/empty rather than
/// failing when a vCard is partial — see `ContactParser`.
final class ContactPayload extends ScanPayload {
  const ContactPayload({
    required this.vCardVersion,
    this.fullName,
    this.givenName,
    this.familyName,
    this.organization,
    this.jobTitle,
    this.phones = const [],
    this.emails = const [],
    this.websites = const [],
    this.addresses = const [],
    this.note,
  });

  /// The `VERSION:` field verbatim (e.g. "3.0"), or "unknown" if absent.
  final String vCardVersion;

  final String? fullName;
  final String? givenName;
  final String? familyName;
  final String? organization;
  final String? jobTitle;
  final List<String> phones;
  final List<String> emails;
  final List<String> websites;
  final List<String> addresses;
  final String? note;
}

/// A `mailto:` payload.
final class EmailPayload extends ScanPayload {
  const EmailPayload({required this.recipients, this.subject, this.body});

  final List<String> recipients;
  final String? subject;
  final String? body;
}

/// A `tel:` payload.
final class PhonePayload extends ScanPayload {
  const PhonePayload({
    required this.rawNumber,
    required this.normalizedNumber,
    this.extension,
  });

  final String rawNumber;
  final String normalizedNumber;
  final String? extension;
}

/// An `sms:`/`smsto:` payload.
final class SmsPayload extends ScanPayload {
  const SmsPayload({required this.recipient, this.body});

  final String recipient;
  final String? body;
}

/// A `geo:` payload. [LocationParser] rejects out-of-range coordinates
/// before this type is ever constructed, so latitude/longitude are always
/// valid here.
final class LocationPayload extends ScanPayload {
  const LocationPayload({
    required this.latitude,
    required this.longitude,
    this.query,
  });

  final double latitude;
  final double longitude;

  /// The `?q=` label/search text, if present (e.g. a venue name).
  final String? query;
}

/// A single, unambiguous point in time as encoded in an iCalendar
/// `VEVENT`, kept as its literal components rather than a [DateTime].
///
/// A `DTSTART` without a `Z` suffix or `TZID` parameter is a *floating*
/// local time with no defined zone — converting it to a concrete
/// [DateTime] would silently assume the device's zone, which the
/// milestone contract forbids ("Do not silently convert uncertain local
/// times"). Callers that need a display string should render the
/// components directly.
class CalendarDateTimeValue {
  const CalendarDateTimeValue({
    required this.year,
    required this.month,
    required this.day,
    this.hour,
    this.minute,
    this.second,
    required this.isUtc,
    this.timeZoneId,
  });

  final int year;
  final int month;
  final int day;

  /// Null for an all-day, date-only value.
  final int? hour;
  final int? minute;
  final int? second;

  /// True only when the original value carried an explicit `Z` (UTC)
  /// suffix.
  final bool isUtc;

  /// The `TZID=` parameter verbatim, if present. Not resolved against a
  /// timezone database (none is bundled in this milestone) — kept only
  /// for display and Milestone 004+ use.
  final String? timeZoneId;

  bool get isDateOnly => hour == null;
}

/// A `BEGIN:VEVENT` payload.
final class CalendarEventPayload extends ScanPayload {
  const CalendarEventPayload({
    this.title,
    this.description,
    this.location,
    this.organizer,
    this.start,
    this.end,
    required this.isAllDay,
  });

  final String? title;
  final String? description;
  final String? location;
  final String? organizer;
  final CalendarDateTimeValue? start;
  final CalendarDateTimeValue? end;
  final bool isAllDay;
}

/// A product-oriented barcode (EAN-8/EAN-13/UPC-A/UPC-E) that is not an
/// ISBN. See [productSymbologies] and `IsbnParser` for how the two are
/// distinguished.
final class ProductPayload extends ScanPayload {
  const ProductPayload({
    required this.identifier,
    required this.symbology,
    required this.digits,
    required this.isCheckDigitValid,
  });

  final String identifier;
  final BarcodeSymbology symbology;
  final String digits;

  /// Null when [symbology] has no check-digit algorithm this milestone
  /// implements (Code 128, Data Matrix, PDF417, Aztec, QR).
  final bool? isCheckDigitValid;
}

/// An ISBN-10 or ISBN-13 payload. Kept separate from [ProductPayload]
/// because an ISBN is a book identifier first — see docs on why not every
/// EAN-13 with a book-ish shape qualifies.
final class IsbnPayload extends ScanPayload {
  const IsbnPayload({
    required this.rawValue,
    required this.format,
    required this.normalized,
    required this.isValidCheckDigit,
  });

  final String rawValue;
  final IsbnFormat format;

  /// The canonical ISBN-13 form (converting an ISBN-10 via the standard
  /// 978 Bookland prefix), used for display and identity so the same book
  /// scanned as either format resolves to one identity.
  final String normalized;

  final bool isValidCheckDigit;
}

/// Freeform text with no recognized structure.
final class PlainTextPayload extends ScanPayload {
  const PlainTextPayload({required this.text}) : characterCount = text.length;

  final String text;
  final int characterCount;
}

/// Content that could not be classified at all — empty after size checks,
/// non-text, or an unsupported structured payload with nothing recoverable
/// as plain text. Never invents an interpretation.
final class UnknownPayload extends ScanPayload {
  const UnknownPayload({required this.rawValue, this.reason});

  final String rawValue;

  /// Short, non-sensitive note on why this fell through — never derived
  /// from or containing [rawValue] itself.
  final String? reason;
}
