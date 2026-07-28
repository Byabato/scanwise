# Execution Plan 003: Domain and Parsing

## Purpose

Implement the authoritative ScanWise domain model — parsed-scan entities,
typed payloads, the parser registry and all scan-type parsers,
normalization, stable content identity, and platform-independent action
descriptors — and map real `ParsedScan` output into the existing
Milestone 002 result presentation, without integrating any capture,
persistence or external-action plugin.

## User-visible result

None directly — this is a pure-Dart domain milestone. Indirect evidence:
the debug component gallery's new "Parsed scans (live)" section shows
real scan values run through the actual parsing pipeline and rendered
through the unmodified `ScanResultView`, alongside the existing
hand-authored fixture catalog.

## Included

- `ParsedScan`, `ScanCandidate`, typed `ScanPayload` hierarchy (12
  variants), `ScanActionDescriptor`;
- `ScanKind`, `BarcodeSymbology`, `ScanSource`, `ScanActionType`,
  `WifiSecurityType`, `IsbnFormat`;
- `ScanPayloadParser` contract, `ScanParseResult`, `ScanParseOutcome`,
  `ParserRegistry` with explicit, tested precedence;
- parsers: URL, Wi-Fi, contact (vCard), email, phone, SMS, location,
  calendar event, product, ISBN, plain text, unknown;
- normalization for URL, phone, product identifier, ISBN, plain text, and
  Wi-Fi/vCard escaping;
- deterministic, documented content identity (`ContentIdentity`,
  `buildContentIdentity`);
- `resolveScanActions` — platform-independent action descriptors per kind;
- `mapParsedScanToResultFixture` — maps `ParsedScan` onto the existing
  `ResultFixture` view model so real scans render through
  `ScanResultView` unmodified;
- payload size limit (`kMaxScanContentLength`) with boundary tests;
- comprehensive pure-Dart unit tests (parsers, registry, normalization,
  identity, actions, mapping);
- this document, `docs/engineering/domain-model.md`,
  `docs/engineering/parsing-strategy.md`,
  `docs/engineering/normalization-and-identity.md`; updates to
  `docs/engineering/data-model.md` and `README.md`.

## Excluded

- mobile_scanner, camera permissions, image_picker;
- Drift/SQLite, any persistence;
- url_launcher, share_plus, contact/calendar platform APIs;
- network requests, online reputation/malware checks;
- analytics, cloud services;
- Milestone 004's URL structural risk *assessment* (findings, severity) —
  `UrlPayload` exposes the structural fields that assessment will need,
  but no assessment is computed;
- rewriting Milestone 002 screens/widgets, or removing the fixture
  gallery.

## Architecture decisions

- **`ParsedScan.identity` doubles as its stable id.** The milestone
  contract asks for "id or stable identity" — read as one field, not two,
  since a deterministic content identity already serves that purpose with
  no persistence layer to assign a separate id yet.
- **Sealed `ScanPayload` hierarchy** instead of `Map<String, String>`,
  split as one file via `part`-free single-library organization (each
  variant is short; splitting into 12 files would work against the
  "cohesive files" guidance more than it would help).
- **Registry fallback via warning accumulation, not branching.** A single
  forward pass through the ordered parser list collects every declined
  parser's failure as a warning; whichever parser eventually succeeds
  inherits them. No special-cased "try plain text next" logic is needed —
  see `docs/engineering/parsing-strategy.md`.
- **Only two hard failures ever reach a caller** (empty, oversized); every
  other malformed-input case degrades to a successful `ParsedScan` with a
  warning, preserving the product promise that an accepted scan always
  produces a result to look at.
- **`CalendarDateTimeValue` instead of `DateTime`** for `DTSTART`/`DTEND`,
  because a floating (zone-less) calendar time cannot become a `DateTime`
  without silently asserting a zone.
- **Content identity is a from-scratch 64-bit hash**, not
  `String.hashCode` (not guaranteed stable across Dart versions) and not a
  new dependency — see `docs/engineering/normalization-and-identity.md`.
- **The presentation mapper targets the existing `ResultFixture` model
  directly** (not a new view-model interface) because that is exactly
  what `ScanResultView` already consumes — the smallest change that lets
  real `ParsedScan` data reach an unmodified M002 widget tree.

## Parser precedence

See `docs/engineering/parsing-strategy.md`. Summary: ISBN → Product → URL
→ Wi-Fi → Contact → Calendar → Email → SMS → Phone → Location → Plain
text → Unknown. Only the ISBN-before-Product ordering is behaviorally
load-bearing; asserted by `test/features/scanning/domain/parsing/parser_registry_test.dart`.

## Normalization rules

See `docs/engineering/normalization-and-identity.md`.

## Identity strategy

See `docs/engineering/normalization-and-identity.md`.

## Failure and fallback policy

See `docs/engineering/parsing-strategy.md`.

## Validation

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

## Progress

- [x] Domain foundation (003A): entities, payloads, parser contracts,
      failure/result types, action descriptors
- [x] Parsers and normalization (003B): all 12 parsers, registry,
      normalization, content identity, tests
- [x] UI mapping and hardening (003C): presentation mapper, gallery
      coexistence, full test suite, documentation, validation

## Assumptions

- `ScanSource` is limited to `camera`/`gallery`, matching the two capture
  paths in `docs/product/v1-scope.md`; widen only if a third capture path
  is added.
- `ScanKind.isbn` renders through `ResultFixtureKind.product` in the
  presentation mapper (own `typeLabel`, shared card shape) since Milestone
  002 has no distinct ISBN card and adding one is out of scope here.
- UPC-E check-digit validation is not implemented (`isCheckDigitValid` is
  always `null` for that symbology) — it requires expansion to UPC-A,
  deferred as a documented limitation.
- Calendar/vCard property parsing takes the first unescaped `:` as the
  property/value boundary, without escape-aware scanning of the property
  segment itself (only vCard/`WIFI:` *values* need escape-aware splitting
  in practice).

## Known limitations

- No persistence exists, so `ContentIdentity` is computed and tested but
  nothing yet reads it back to detect a repeat scan.
- Wi-Fi identity intentionally ignores the password value (see
  `docs/engineering/normalization-and-identity.md`).
- Contact identity is deliberately conservative and can treat the same
  physical business card as a new identity if a field is corrected
  between scans.
- A real `ScanKind.url` result renders without a security panel this
  milestone (`ResultFixture.security` is always `null`) — Milestone 004
  adds the structural assessment.

## Deferred to Milestone 004

- URL structural risk assessment (HTTP, IP-address host, unusual port,
  embedded credentials, excessive subdomains, punycode, suspicious
  Unicode, shortener patterns, misleading organization-in-subdomain) —
  computed from `UrlPayload`'s already-exposed structural fields.
- Wiring `ScanActionDescriptor.requiresConfirmation` into an actual
  confirmation flow (the existing `ConfirmationSheet` widget isn't yet
  invoked from action dispatch).

## Recommended next step

Milestone 004: implement the URL structural risk assessment on top of
`UrlPayload`, and wire it into `ParsedScan.structuralAssessment` and the
presentation mapper's `security` field.

## Completion report

See the conversation's completion report for the full accounting of
files, tests, and validation results.

Do not commit or push.
