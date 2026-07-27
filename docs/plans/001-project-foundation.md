# Execution Plan 001: Project Foundation

## Purpose

Create the initial Android-first Flutter foundation for ScanWise without
implementing scanner, database or production feature logic.

## User-visible result

A runnable Android application containing:

- splash or launch treatment;
- onboarding shell;
- Scan, Library and Settings navigation;
- centralized Material 3 design tokens;
- static destination placeholders;
- initial automated tests.

## Current state

Environment audited (Flutter 3.35.2 stable, Dart 3.9.0, Java 17, Android SDK
36, adb, one Android emulator image, Git 2.41.0). No blockers found. The
repository previously contained only product, design and engineering
documentation, visual Stitch references and repository instructions; this
plan generates the first Flutter project into it.

## Included

- environment audit;
- Flutter project creation;
- Android package configuration;
- Material 3;
- Riverpod;
- GoRouter;
- centralized design tokens;
- main navigation shell;
- initial onboarding;
- real (non-placeholder) foundation UI for Scan, Library and Settings;
- test foundation;
- GitHub Actions;
- README update.

## Excluded

- mobile_scanner;
- camera permissions;
- image picker;
- permission_handler;
- url_launcher;
- share_plus;
- Drift;
- SQLite;
- scan parsing;
- URL assessment;
- persistent Library;
- real external actions;
- release signing;
- code generation (build_runner, freezed, json_serializable);
- a service locator;
- a generic repository layer.

## Environment

- Windows
- Flutter 3.35.2 stable
- Dart 3.9.0
- Java 17
- Android SDK 36 (build-tools 36.0.0, platforms 28-36 installed)
- Flutter project name: `scanwise`
- App display name: ScanWise
- Android package ID: `com.kelvinbyabato.scanwise`
- Minimum Android SDK: 24 (see "Minimum SDK decision" below)
- Platform target: Android only

## Minimum SDK decision

23 was originally requested. Flutter 3.35.2's Gradle tooling includes
`MinSdkVersionMigration`, which rewrites any `minSdk` value of 23 or lower in
`android/app/build.gradle.kts` back to `flutter.minSdkVersion` (currently 24)
on every `flutter build` or `flutter run` — setting `minSdk = 23` directly
does not survive a single build. This was discovered during validation, not
assumed in advance. Presented as a choice, the product decision was to
**accept minSdk 24** (Android 7.0+) rather than pin an older Flutter/AGP
toolchain. `AGENTS.md` has been updated to reflect 24 as the current floor.

## Assumptions

- The existing git remote (`origin` → github.com/Byabato/scanwise) and branch
  layout (`main` tracking `origin/master`) are left untouched.
- `flutter create` must not run directly on top of `docs/`, `AGENTS.md`,
  `README.md` or `.gitignore`; the project is generated in an isolated
  scratch directory and the generated Android/Flutter scaffolding is copied
  in, preserving every existing file.
- CI validates debug builds only; no signing configuration is introduced.
- Design tokens approximate the Stitch reference direction (warm neutral
  surfaces, restrained forest-green accent) using the palette recorded in
  `docs/design/design-system.md`, adjusted only for contrast where required.

## Required process

1. Audit installed Flutter, Dart, Java, Android SDK, Git and device tooling.
2. Report blockers before changing files.
3. Generate the Flutter project (in a scratch directory, then merge in)
   without disturbing existing documentation or history.
4. Preserve and merge existing documentation and `.gitignore`.
5. Add only `flutter_riverpod` and `go_router` as dependencies.
6. Create centralized design tokens.
7. Implement navigation and the onboarding, Scan, Library and Settings shells.
8. Add focused tests.
9. Configure CI.
10. Run all acceptance commands and report results before considering the
    milestone complete.

## Acceptance criteria

- App display name is ScanWise.
- Flutter project name is `scanwise`.
- Android package ID is `com.kelvinbyabato.scanwise`.
- Minimum Android SDK is 24 (see "Minimum SDK decision").
- Material 3 is enabled.
- Scan, Library and Settings are navigable from a persistent bottom
  navigation shell, reached after onboarding completes.
- Navigation state (selected tab) survives switching between destinations.
- Design tokens exist for colors, spacing, shape, typography, elevation and
  motion, and feature widgets do not hard-code arbitrary visual constants.
- Foundation UI is real (scan frame, empty state, settings rows), not plain
  placeholder text, while remaining honest about what is not yet wired up.
- Tests cover app launch, onboarding, navigation and key screen states.
- No scanner, database, gallery, permission or external-action dependency is
  added.
- Documentation reflects the implemented setup.

## Validation

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

## Completion report

Report:

- files created or changed;
- dependencies added;
- commands executed;
- exact test outcomes;
- build outcome and APK path;
- assumptions;
- remaining risks and limitations;
- next recommended milestone.

Do not commit or push.

## Progress

- [x] Environment audited
- [x] Flutter project generated
- [x] Android identity configured
- [x] Theme foundation implemented
- [x] Router implemented
- [x] Navigation shell implemented
- [x] Onboarding shell implemented
- [x] Tests added
- [x] CI configured
- [x] Documentation updated
- [x] Validation passed
