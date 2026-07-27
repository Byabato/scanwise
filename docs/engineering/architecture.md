# ScanWise Architecture

## Objective

Use an architecture that supports:

- reliable camera integration;
- deterministic domain tests;
- local persistence;
- feature growth;
- clear privacy boundaries;
- manageable complexity.

## Structure

Use a feature-first structure.

Expected top-level source organization:

```text
lib/
  app/
  core/
  features/
  shared/



  Boundaries
Presentation

Owns:

Flutter screens;
widgets;
navigation;
view-specific behavior;
rendering of application state.
Application

Owns:

Riverpod controllers;
use-case orchestration;
state transitions;
interaction between domain and infrastructure.
Domain

Owns:

parsed scan models;
scan-kind classification;
content parsing;
validation;
URL normalization;
structural assessment;
duplicate policy;
action descriptions.

Domain code should be as independent of Flutter and plugins as practical.

Infrastructure

Owns:

mobile_scanner integration;
gallery selection;
permissions;
SQLite or Drift;
platform action launching;
sharing;
device settings.
Core rule

Plugin-specific types must be mapped at the integration boundary.

The rest of the app should not depend directly on mobile_scanner barcode
objects.

State management

Use Riverpod.

Prefer:

Notifier for synchronous application state;
AsyncNotifier for persistent or asynchronous workflows;
provider-based dependency injection;
isolated provider tests.

Do not create one global application controller.

Navigation

Use GoRouter.

Primary destinations:

Scan;
Library;
Settings.

Result sheets should not become unnecessary standalone routes unless deep
linking, restoration or interaction complexity requires it.

Error handling

Distinguish:

permission failures;
scanner initialization failures;
no-code gallery results;
malformed content;
unsupported content;
persistence failures;
unavailable external actions;
unexpected internal failures.

Errors must produce actionable, human-readable UI states.

Logging

Logging must never expose raw scan values.

Use metadata such as:

scan kind;
source;
operation;
non-sensitive error category.
Dependency policy

Avoid adding a package where Flutter or Dart provides a sufficient stable
capability.

Approved package direction is documented in AGENTS.md.

