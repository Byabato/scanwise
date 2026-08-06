# ScanWise Privacy and Security

## Core privacy promise

Scan contents are processed locally by default and are not uploaded by the
application.

## Sensitive content

Scans may contain:

- private URLs;
- passwords;
- contact information;
- phone numbers;
- email addresses;
- business identifiers;
- payment instructions;
- internal resources;
- event information;
- location information.

Treat all raw scan content as potentially sensitive.

## Requirements

- no raw values in logs;
- no raw values in analytics;
- no raw values in crash reporting;
- no automatic external actions;
- explicit user action before opening concerning destinations;
- Wi-Fi passwords masked by default;
- incognito scans are not persisted;
- clear-history controls are available;
- destructive actions are confirmed where appropriate;
- permissions are requested contextually;
- no unnecessary Android permissions.

## URL analysis

The application may identify local structural indicators.

It must not state that a destination is definitively safe or malicious.

Each finding should include:

- code;
- severity;
- title;
- explanation;
- technical detail where helpful.

URL structural analysis (Milestone 004) is local-only and deterministic: it
performs no network, DNS, redirect, certificate, WHOIS, or reputation
requests. Findings never carry embedded credentials or raw query values; a
nested-destination finding exposes only the safe parameter name. See
[url-structural-analysis.md](url-structural-analysis.md) for the finding
catalogue, severity policy and documented limitations.

## External actions

Before external actions:

- validate the URI or target;
- ensure the action is supported;
- present appropriate confirmation;
- handle failures without losing user state.

## Secrets

Never commit:

- signing keystores;
- signing passwords;
- API keys;
- service-account files;
- production tokens;
- developer credentials.

## Future services

Any future cloud service, online reputation service, crash reporter or
analytics SDK requires a separate privacy and threat review before
implementation.
