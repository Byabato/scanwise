
---

# 15. `docs/plans/001-project-foundation.md`

```md
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

The repository contains only:

- product documentation;
- design documentation;
- engineering documentation;
- visual Stitch references;
- repository instructions.

No Flutter project has been generated.

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
- placeholder primary destinations;
- test foundation;
- GitHub Actions;
- README update.

## Excluded

- mobile_scanner;
- camera permissions;
- image picker;
- Drift;
- scan parsing;
- URL assessment;
- persistent Library;
- real external actions;
- release signing.

## Required process

1. Audit installed Flutter, Dart, Java, Android SDK, Git and device tooling.
2. Report blockers before changing files.
3. Generate the Flutter project in the current repository.
4. Preserve and merge existing documentation and `.gitignore`.
5. Add only dependencies needed for the application shell.
6. Create centralized design tokens.
7. Implement navigation.
8. Add focused tests.
9. Configure CI.
10. Run all acceptance commands.

## Acceptance criteria

- App display name is ScanWise.
- Flutter project name is `scanwise`.
- Android package ID is `com.kelvinbyabato.scanwise`.
- Minimum Android SDK is 23.
- Material 3 is enabled.
- Scan, Library and Settings are navigable.
- Navigation state behaves predictably.
- Design tokens exist for colors, spacing, shape, typography and motion.
- No feature widget hard-codes arbitrary visual constants.
- Tests cover the application shell and navigation.
- No scanner, database or gallery dependency is added.
- Documentation reflects the implemented setup.

## Validation

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug



Completion report

Report:

files created or changed;
dependencies added;
commands executed;
exact test outcomes;
build outcome;
assumptions;
remaining risks;
next recommended milestone.

Do not commit or push.

Progress
 Environment audited
 Flutter project generated
 Android identity configured
 Theme foundation implemented
 Router implemented
 Navigation shell implemented
 Onboarding shell implemented
 Tests added
 CI configured
 Documentation updated
 Validation passed