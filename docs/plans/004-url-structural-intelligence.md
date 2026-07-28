# Execution Plan 004: URL structural intelligence

## Purpose

Add deterministic, local-only URL structural findings to authoritative
`ParsedScan` data and render the same assessment through live and fixture result
components.

## Completed

- [x] 004A: assessment model, finding catalogue, thresholds, scheme/host/port
- [x] 004B: credentials, IP/local ranges, subdomains, Unicode, shorteners,
      length/encoding, aggregation, action confirmation
- [x] 004C: presentation mapping, debug presets, tests, documentation

## Decisions

- Highest severity determines overall severity; stable code ordering breaks ties.
- The UI uses “Destination host”; no registrable-domain claim or dependency.
- Shorteners use a replaceable exact-match local catalogue.
- Organization-name-in-subdomain analysis is deferred to avoid unsupported
  ownership claims and false positives.
- All analysis is offline and pure Dart; no production dependency was added.

## Validation

Run formatting, analysis, all tests, and a debug APK build. Manual emulator
comparison remains a human visual-review task when an emulator is available.

