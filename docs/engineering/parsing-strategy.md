# ScanWise Parsing Strategy (Milestone 003)

## Parser contract

```dart
abstract interface class ScanPayloadParser {
  bool canParse(ScanCandidate candidate);
  ScanParseResult parse(ScanCandidate candidate);
}
```

`canParse` does one cheap, decisive check (a scheme prefix, a symbology +
shape check, a structural marker). Once it returns true, `parse` must
always return a `ScanParseResult` — `ScanParseSuccess` or
`ScanParseFailed` — and must never throw, even for adversarial or
malformed input.

## Parser order (`ParserRegistry.defaultScanPayloadParsers`)

```text
1.  IsbnParser
2.  ProductParser
3.  UrlParser
4.  WifiParser
5.  ContactParser
6.  CalendarParser
7.  EmailParser
8.  SmsParser
9.  PhoneParser
10. LocationParser
11. PlainTextParser   (universal text fallback)
12. UnknownParser     (absolute last resort, always matches)
```

Only one ordering decision is load-bearing: **`IsbnParser` before
`ProductParser`**. Both can match a bare numeric EAN-13 value; `IsbnParser`
only claims a 978/979-prefixed (Bookland) EAN-13, and `ProductParser`
never sees a value `IsbnParser` already claimed. Every other parser
matches on a distinct scheme prefix or structural marker (`http(s)://`,
`WIFI:`, `BEGIN:VCARD`, `BEGIN:VEVENT`, `mailto:`, `sms(to):`, `tel:`,
`geo:`), so their relative order doesn't change behavior — they're listed
by specificity for readability. `PlainTextParser`/`UnknownParser` must
stay last; this ordering is asserted by
`parser_registry_test.dart`'s `precedence` group.

Symbology, not just text shape, disambiguates a "product": `ProductParser`
and `IsbnParser` both require `candidate.symbology` to be a product-shaped
barcode (EAN-8/EAN-13/UPC-A/UPC-E) — a QR code containing the same digits
is ordinary text, since `BarcodeSymbology.qrCode` is never in
`productSymbologies`.

## Fallback policy

`ParserRegistry.parse` runs a structural gate before any parser sees the
candidate, then a single forward pass through the ordered parser list:

1. **Empty content** → `ScanParseOutcomeFailure(EmptyContentFailure())`.
   The only case with nothing at all to show the user.
2. **Oversized content** (`> kMaxScanContentLength`, 8192 characters, see
   `parsing_limits.dart`) → `ScanParseOutcomeFailure(OversizedContentFailure(...))`.
   These two are the **only** outcomes a caller ever sees as a hard
   failure — see [Payload size protection](#payload-size-protection).
3. Otherwise, walk the ordered parsers. Each declines (`canParse` false),
   succeeds, or fails having committed (`canParse` true, `parse` returns
   `ScanParseFailed`). Every failure encountered along the way is
   collected as a `ScanParseWarning` (via `ScanParseWarning.fromFailure`);
   the walk continues. The first parser to succeed wins, and its
   `ParsedScan.warnings` includes every warning collected before it —
   so if `WifiParser` commits and fails, and `PlainTextParser`
   subsequently succeeds, the plain-text result carries a
   `malformed-wifi` warning explaining what was attempted.
4. `UnknownParser` always matches and always succeeds, so the walk is
   guaranteed to terminate in a success — the registry never needs a
   "no parser matched" branch. A final defensive fallback exists anyway
   (never throw, even on a future parser-list misconfiguration).

This means: **an accepted scan (anything that reaches the parser at all)
always gets a `ParsedScan` to show the user.** Only the two structural
gate failures block that promise, and both are cases where there is
either nothing to show (empty) or showing it safely isn't guaranteed
(oversized).

### Per-case policy

| Situation | Outcome |
|---|---|
| Empty content | Hard failure (`EmptyContentFailure`) |
| Oversized content | Hard failure (`OversizedContentFailure`) |
| Malformed URL (bad scheme, unparsable, malformed `%xx`) | Degrades to plain text + warning |
| Malformed Wi-Fi (missing SSID) | Degrades to plain text + warning |
| Wi-Fi with an unrecognized `T:` value | **Succeeds** as `wifi` with `WifiSecurityType.unknown` + `securityRaw` preserved (not a warning — a legitimate, if unusual, network) |
| Incomplete vCard (`END:VCARD` missing) | Degrades to plain text + warning |
| A structurally-complete but field-empty vCard | **Succeeds** as `contact` with a warning (structure was fine, content wasn't there) |
| A vCard with one malformed property line | **Succeeds** as `contact`; that one line is skipped, everything else is kept |
| Invalid/out-of-range `geo:` coordinates | Degrades to plain text + warning |
| Missing/unparsable `DTSTART` | Degrades to plain text + warning |
| Missing `DTEND` | **Succeeds** as `calendarEvent` with a warning (an event can have no listed end) |
| Invalid ISBN/EAN/UPC check digit | **Succeeds** with `isValidCheckDigit: false` + warning — the identifier is still shown, just flagged. Never rejected: check-digit validity is a data quality signal, not a parse precondition |
| Unsupported/empty structured value (e.g. `mailto:` with no recipient) | Degrades to plain text + warning |
| Content that isn't displayable text at all (replacement character, control bytes) | `PlainTextParser` declines; `UnknownParser` produces `unknown` + warning |

## Payload size protection

`kMaxScanContentLength = 8192` (`parsing/parsing_limits.dart`) bounds
`ScanCandidate.rawValue` before any parser runs. Chosen well above any
realistic QR/barcode payload (PDF417 tops out in the low thousands of
characters at typical error correction; a vCard with an embedded photo is
the one common payload that could approach this) while still bounding
worst-case parsing cost against a maliciously or accidentally huge
decoded value. The payload itself is never logged in the failure
(`OversizedContentFailure` carries only `length`/`maxLength`, both plain
integers). Boundary tests exist at exactly `kMaxScanContentLength` (must
succeed) and `kMaxScanContentLength + 1` (must fail) —
`parser_registry_test.dart`'s `structural gates` group.

## Never throw

No parser, and no part of `ParserRegistry`, should ever let an exception
escape for user-controlled input. This is enforced by construction (every
branch returns a `ScanParseResult`) rather than by blanket `try/catch` —
a parser that could throw indicates a missing case, not something to
swallow silently.
