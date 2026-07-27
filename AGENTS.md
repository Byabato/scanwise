# AGENTS.md

## Product

ScanWise is a privacy-first Android scan-intelligence application.

It captures QR codes and barcodes, interprets their contents, highlights
structural risks, presents controlled actions, and organizes useful scans
in a local searchable library.

The scanner is the input mechanism. The product value is interpretation,
decision support, privacy, and organization.

## Current platform

- Flutter and Dart
- Android first
- Material 3
- Minimum Android SDK: 23
- Package ID: com.kelvinbyabato.scanwise

## Architecture

Use feature-first organization with limited layering:

- presentation: widgets, screens, navigation, UI state
- application: Riverpod controllers and orchestration
- domain: pure business models, parsing, validation, security rules
- infrastructure: plugins, database, permissions, platform actions

Do not add abstractions unless they:
1. isolate a plugin,
2. enable deterministic testing,
3. separate persistence, or
4. define a meaningful business boundary.

Do not expose mobile_scanner plugin models outside the scanner integration
boundary.

## Technology decisions

- State management: Riverpod
- Navigation: GoRouter
- Local database: Drift with SQLite
- Camera scanning: mobile_scanner
- Gallery selection: image_picker
- Permissions: permission_handler
- External actions: url_launcher
- Sharing: share_plus
- Tests: flutter_test, mocktail, integration_test
- Model generation may use Freezed only where it materially reduces
  error-prone boilerplate.

Do not add or replace a production dependency without explaining:
- the need,
- alternatives considered,
- maintenance implications,
- licensing implications.

Ask for approval before adding a production dependency.

## Design rules

The Stitch references in docs/design/references are the visual source of truth.

Design character:
- calm,
- minimal,
- modern,
- trustworthy,
- premium,
- accessible.

Do not introduce:
- gradients,
- glassmorphism,
- neon scanner effects,
- excessive cards,
- generic AI visuals,
- decorative dashboards,
- raw payloads as primary content.

Use centralized design tokens. Do not hard-code arbitrary colors, radii,
spacing, text styles, or animation durations inside feature widgets.

Use:
- Material 3 behavior,
- minimum 48 dp touch targets,
- semantic labels,
- large-text resilience,
- clear loading, empty, error, disabled, pressed, and selected states.

## Privacy and security

- Never automatically open scanned content.
- Never claim a URL is definitively safe.
- Use cautious structural-risk language.
- Never log raw scan values.
- Never include raw scan content in analytics, crash reports, or test output.
- Process scan contents locally by default.
- Store scans only according to the user's history/incognito settings.
- Mask Wi-Fi passwords by default.
- Require explicit confirmation before risky external actions.
- No secrets, signing keys, service-account files, API tokens, or local
  environment values may be committed.

## Code standards

- Prefer immutable state.
- Prefer small focused widgets and pure functions.
- Avoid files over approximately 400 lines unless cohesion justifies it.
- Avoid catch-all utility classes.
- Use explicit names rather than abbreviations.
- Handle failures using typed application/domain failures where useful.
- Do not silently swallow exceptions.
- Write comments only for non-obvious reasoning, invariants, or limitations.
- Format all modified Dart files.

## Testing expectations

Every behavior change must include proportionate tests.

Run before completing a task:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test