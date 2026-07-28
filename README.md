# ScanWise

Current milestone: **004 — URL structural intelligence**. URL scans receive
deterministic, offline structural findings and responsible result presentation.
See `docs/engineering/url-structural-analysis.md`.

ScanWise is a privacy-first Android scan-intelligence application.

It helps users capture, understand, assess, act on and organize information
contained in QR codes and barcodes.

## Product principle

The scanner is the capture mechanism.

The product value is:

- explaining scanned information;
- revealing actual URL destinations;
- identifying structural warning signs;
- presenting context-aware actions;
- organizing useful scans into a local searchable library.

## Core flow

Capture → Interpret → Assess → Act → Organize

## Initial platform

- Flutter
- Android first
- Material 3
- Local-first processing
- No analytics in version 1

## Status

- Project foundation milestone complete (`docs/plans/001-project-foundation.md`):
  a runnable Android Flutter shell with onboarding, Material 3 design tokens,
  and Scan / Library / Settings navigation.
- Static UI milestone complete (Milestone 002): the Scanner result sheet,
  all 12 result kinds, and the Library/Settings screens, built against
  hand-authored fixtures.
- Domain and parsing milestone complete (`docs/plans/003-domain-and-parsing.md`):
  the authoritative `ParsedScan` domain model, normalization, a
  precedence-ordered parser registry covering every Milestone 002 result
  kind plus ISBN, deterministic content identity, and a mapper from real
  `ParsedScan` output onto the existing result UI. See
  `docs/engineering/domain-model.md`, `docs/engineering/parsing-strategy.md`
  and `docs/engineering/normalization-and-identity.md`.

No scanner, persistence, permissions or real external actions are
implemented yet — parsing is pure Dart and runs on hand-built or
debug-gallery input only.

## Documentation

- Product contract: `docs/product/product-contract.md`
- Version 1 scope: `docs/product/v1-scope.md`
- Design system: `docs/design/design-system.md`
- Architecture: `docs/engineering/architecture.md`
- Testing strategy: `docs/engineering/testing-strategy.md`
- Privacy and security: `docs/engineering/privacy-and-security.md`
- Domain model: `docs/engineering/domain-model.md`
- Parsing strategy: `docs/engineering/parsing-strategy.md`
- Normalization and identity: `docs/engineering/normalization-and-identity.md`
- Foundation execution plan: `docs/plans/001-project-foundation.md`
- Domain and parsing execution plan: `docs/plans/003-domain-and-parsing.md`

## Environment requirements

- Windows, macOS or Linux
- Flutter 3.35.2 (stable channel)
- Dart 3.9.0 (bundled with the above Flutter version)
- Java 17
- Android SDK 36 (platform-tools, build-tools 36.0.0, an Android platform
  image, and one emulator or a physical device)

Verify your machine with:

```bash
flutter doctor -v
```

## Setup

```bash
flutter pub get
```

The project was generated with:

```bash
flutter create \
  --org com.kelvinbyabato \
  --project-name scanwise \
  --platforms android \
  .
```

## Run

```bash
flutter emulators --launch <emulator-id>   # or connect a physical device
flutter run
```

## Validation

Run before completing any task:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

## Current limitations

- No camera or gallery scanning (`mobile_scanner`, `image_picker` are not
  added yet).
- No permission requests (`permission_handler` is not added yet).
- No persistence: the Library is always empty, and onboarding is shown again
  on every cold start since completion is not remembered.
- No real external actions (`url_launcher`, `share_plus` are not added yet).
- The theme preference in Settings is functional but session-only; it is not
  saved between launches.
- No release signing configuration.
