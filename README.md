
---

# 2. `README.md`

```md
# ScanWise

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

Pre-development planning and repository setup.

## Documentation

- Product contract: `docs/product/product-contract.md`
- Version 1 scope: `docs/product/v1-scope.md`
- Design system: `docs/design/design-system.md`
- Architecture: `docs/engineering/architecture.md`
- Testing strategy: `docs/engineering/testing-strategy.md`
- Privacy and security: `docs/engineering/privacy-and-security.md`

## Planned setup

The Flutter project will be generated using:

```bash
flutter create \
  --org com.kelvinbyabato \
  --project-name scanwise \
  --platforms android \
  .