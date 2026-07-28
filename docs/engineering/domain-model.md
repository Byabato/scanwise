# ScanWise Domain Model (Milestones 003–004)

## Structural URL assessment

URL `ParsedScan` instances carry an authoritative `StructuralAssessment` made
of ordered `StructuralFinding` values and a `RiskLevel` (`none`, `information`,
`caution`, `high`). The highest finding severity determines the overall level.
Presentation maps this model one-way and contains no duplicate security logic.

## Location

`lib/features/scanning/domain/` — pure Dart, no Flutter/plugin imports
except `parsed_scan_presentation_mapper.dart` (in `presentation/mapping/`,
outside the domain layer), which needs `IconData`.

```text
lib/features/scanning/domain/
  entities/       ParsedScan, ScanCandidate, ScanPayload (+ variants),
                   ScanActionDescriptor
  enums/          ScanKind, BarcodeSymbology, ScanSource, ScanActionType,
                   WifiSecurityType, IsbnFormat
  parsing/        ScanPayloadParser, ScanParseResult, ScanParseOutcome,
                   ParserRegistry, parsing_limits.dart, parsers/*
  normalization/  one file per normalization rule + escaping.dart
  identity/       ContentIdentity, buildContentIdentity
  actions/        resolveScanActions
  failures/       ScanParseFailure, ScanParseWarning
```

## ParsedScan

The authoritative interpretation of one scan — the contract Milestone
002's `ResultFixture` stood in for. Fields:

- `identity` — a [`ContentIdentity`](normalization-and-identity.md); this
  doubles as the "id or stable identity" the milestone contract requires,
  since a stable content identity *is* the natural identity for a parse
  result (there is no separate persistence-assigned id yet).
- `rawValue` — exact decoded text, never mutated.
- `normalizedValue` — kind-specific canonical string (see
  [normalization-and-identity.md](normalization-and-identity.md)).
- `kind`, `symbology`, `source`, `capturedAt`.
- `title`, `subtitle` — human-readable headline/detail.
- `payload` — the typed [`ScanPayload`](#typed-payloads).
- `attributes` — flat, already-human-labeled technical metadata (e.g.
  `{'Symbology': 'QR Code'}`) for the technical-details section. The one
  place a `Map<String,String>` is appropriate, since these are always
  non-sensitive metadata *about* the scan, never the interpreted content.
- `actions` — [`ScanActionDescriptor`](#action-descriptors) list.
- `warnings` — non-fatal parse issues (see
  [parsing-strategy.md](parsing-strategy.md)).
- `structuralAssessment` — reserved for Milestone 004's URL/security
  assessment; always `null` in this milestone.

**Deliberately excluded**: `note`, `favorite`, `collectionId`, saved
status, occurrence/scan count. Those are user-editable Library metadata,
recorded against a scan's `identity` by a later persistence milestone —
not part of the parse result itself.

## Typed payloads

`ScanPayload` is a sealed class (`entities/scan_payload.dart`) with one
subtype per `ScanKind`: `UrlPayload`, `WifiPayload`, `ContactPayload`,
`EmailPayload`, `PhonePayload`, `SmsPayload`, `LocationPayload`,
`CalendarEventPayload` (+ `CalendarDateTimeValue`), `ProductPayload`,
`IsbnPayload`, `PlainTextPayload`, `UnknownPayload`. Each exposes only the
structured fields meaningful for its kind — no single
`Map<String, String>` interpretation. Being sealed means every `switch`
over `ScanPayload` (the action resolver, the identity builder, the
presentation mapper) is exhaustive and compiler-checked.

`CalendarDateTimeValue` is its own small value type rather than
`DateTime`, specifically because a floating (zone-less) `DTSTART` cannot
be represented as a `DateTime` without falsely implying a zone — see
[normalization-and-identity.md](normalization-and-identity.md).

## Action descriptors

`ScanActionDescriptor` (type, label, enabled, disabledReason,
requiresConfirmation, copyValue, isSensitive, isPrimary) describes
*intent* only — no `BuildContext`, `IconData`, or platform call anywhere
in the domain layer. `resolveScanActions` (`actions/scan_action_resolver.dart`)
derives the descriptor list per kind, matching the per-kind action
inventory in docs/product/product-contract.md pillar 3. Exactly one
descriptor is `isPrimary` per call, and `copy`/`share`/`save` are always
`enabled` (see that file's doc comment for why). Presentation
(`parsed_scan_presentation_mapper.dart`) turns each descriptor into a
`ResultActionFixture` with a UI tier.

## Failures

`ScanParseFailure` (sealed, `failures/scan_parse_failure.dart`) and
`ScanParseWarning` are covered in
[parsing-strategy.md](parsing-strategy.md).

## Relationship to `docs/engineering/data-model.md`

That document is the persistence-oriented data model (`scans`,
`scan_metadata`, `scan_occurrences` tables) targeted by a future
milestone. This document is its immediate predecessor: the in-memory,
pre-persistence domain model `ParsedScan` maps into those tables later.
