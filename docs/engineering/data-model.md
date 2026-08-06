# ScanWise Data Model

> **Milestone 003 status**: the in-memory `ParsedScan` domain model,
> parsing, normalization and content-identity concepts described below are
> now implemented in `lib/features/scanning/domain/`. See
> [domain-model.md](domain-model.md) for the implemented model,
> [parsing-strategy.md](parsing-strategy.md) for parser order and fallback
> policy, and [normalization-and-identity.md](normalization-and-identity.md)
> for normalization rules and the content-identity algorithm. The
> `scans`/`scan_metadata`/`scan_occurrences`/`collections`/`settings`
> persistence tables below remain **not yet implemented** — no Drift/SQLite
> integration exists yet, and duplicate-recognition *behavior* (reading
> `ContentIdentity` back to detect a repeat scan) is deferred to that
> persistence milestone. Milestone 004's `StructuralAssessment`/
> `StructuralFinding`/`RiskLevel` are also now implemented — see
> [domain-model.md](domain-model.md) and
> [url-structural-analysis.md](url-structural-analysis.md).

## Parsed scan

The authoritative interpreted scan model should contain:

- ID;
- content hash;
- raw value;
- scan kind;
- symbology;
- scan source;
- captured time;
- human-readable title;
- subtitle;
- structured attributes;
- optional structural assessment.

## Suggested domain concepts

```text
ParsedScan
ScanKind
BarcodeSymbology
ScanSource
SecurityAssessment
SecurityFinding
RiskLevel
ScanAction
```

### Scan kind

Initial values:

- URL;
- Wi-Fi;
- contact;
- email;
- phone;
- SMS;
- location;
- calendar event;
- product;
- ISBN;
- plain text;
- unknown.

### Security assessment

Should contain:

- overall severity;
- list of findings;
- stable finding codes;
- user-facing title;
- plain-language explanation;
- optional technical detail.

It must not imply live reputation certainty.

## Persistence

Expected logical tables:

### scans

Stable interpreted content:

- ID;
- content hash;
- raw value;
- kind;
- symbology;
- source;
- title;
- subtitle;
- structured attributes;
- security assessment;
- first scanned time.

### scan_metadata

User-controlled metadata:

- scan ID;
- custom title;
- note;
- collection ID;
- favorite;
- last scanned time;
- occurrence count.

### scan_occurrences

Repeated scan records:

- occurrence ID;
- scan ID;
- source;
- captured time.

### collections

- ID;
- name;
- description;
- created time;
- updated time.

### settings

Only settings that require persistent local storage.

## Duplicate identity

Duplicate recognition should be based on a stable normalized representation
where appropriate.

Examples:

- normalized URL rather than superficial formatting;
- exact Wi-Fi configuration where safe;
- normalized product identifier;
- stable raw content hash as fallback.

The duplicate strategy must have unit tests and documented limitations.