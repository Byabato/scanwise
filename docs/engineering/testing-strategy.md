# ScanWise Testing Strategy

## Testing levels

### Unit tests

Use for:

- parsers;
- URL normalization;
- security assessment;
- content hashes;
- duplicate policies;
- action resolution;
- state transitions;
- filtering and sorting;
- repository behavior using in-memory storage.

### Widget tests

Use for:

- result hierarchy;
- buttons and actions;
- warning rendering;
- raw-detail expansion;
- empty states;
- loading states;
- error states;
- search and filters;
- navigation;
- settings;
- accessibility semantics;
- large-text behavior;
- narrow-screen behavior.

### Integration tests

Use injected fake scan sources for deterministic flows:

- onboarding;
- normal URL;
- concerning URL;
- save and reopen;
- duplicate scan;
- collections;
- incognito;
- clear data;
- gallery result handling where native selection is abstracted.

### Real-device tests

Required for:

- live camera;
- Android permissions;
- permanently denied permission;
- torch;
- gallery picker;
- application background and resume;
- interruption by calls or other apps;
- different Android versions;
- low-light scanning;
- slow devices;
- release builds.

## Required unit-test categories

Each parser or structural rule should include:

- normal case;
- negative case;
- boundary case;
- malformed input;
- failure-safe behavior.

## URL cases

Include:

- HTTPS;
- HTTP;
- malformed URI;
- IP-address host;
- IPv6 host;
- embedded credentials;
- unusual port;
- excessive subdomains;
- punycode;
- Unicode characters;
- shortened URL;
- unsupported scheme;
- localhost or private host where relevant;
- encoded delimiters;
- nested URL parameters.

## Test principles

- deterministic;
- independent;
- no network dependency for core tests;
- no raw sensitive values in failure logs where avoidable;
- do not test private implementation details unnecessarily;
- do not replace meaningful assertions with broad snapshots;
- do not delete tests merely to restore a green build.

## Validation commands

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test/
flutter build apk --debug