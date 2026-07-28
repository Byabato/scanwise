# ScanWise Normalization and Content Identity (Milestone 003)

## Normalization rules

`rawValue` is never changed. `normalizedValue` is a separate, kind-specific
canonical representation — general principle: **normalize only what is
safe to normalize; never rewrite or lowercase indiscriminately.**

| Kind | Rule | File |
|---|---|---|
| URL | Lowercase scheme and host (case-insensitive per RFC 3986); drop an explicit port that matches the scheme's default; keep path/query/fragment byte-for-byte (no reordering, decoding, or case changes); **drop embedded user-info** (credentials aren't part of a URL's "site identity", and Milestone 004's findings read `hasUserInfo` directly from the payload, not this string) | `normalization/url_normalization.dart` |
| Phone | Strip formatting punctuation (spaces, hyphens, parens, dots); preserve a single leading `+` if present; no country-code inference or validation | `normalization/phone_normalization.dart` |
| Product identifier | Trim surrounding whitespace only; **leading zeros are preserved** — they're significant in a GTIN | `normalization/product_identifier_normalization.dart` |
| ISBN | Always canonicalize to ISBN-13 (an ISBN-10 is converted via the standard `978` Bookland prefix and a recomputed check digit); the originally-scanned format is kept separately on `IsbnPayload.format` for display | `normalization/isbn_normalization.dart` |
| Plain text | **Identity transform** — `normalizedValue == rawValue`. Case, whitespace and punctuation can all carry meaning in freeform text, so nothing is inferred safe to change | `normalization/text_normalization.dart` |
| Wi-Fi | Not a single string transform — see [Wi-Fi identity](#wi-fi-identity) below | `identity/content_identity_builder.dart` |
| Contact, email, phone, sms, location, calendarEvent, unknown | `normalizedValue` is a kind-specific composite/display string built by the parser (e.g. the contact's resolved title, `"lat,lon"` at fixed precision, `"title|dateKey"` for an event) — not independently documented per-field since these aren't reused as normalization primitives elsewhere | respective parser files |

Escaping (shared, not really "normalization" but adjacent): `WIFI:` and
vCard values both backslash-escape a small delimiter set. `unescapeWifiValue`/
`unescapeVCardValue` and the escape-aware `splitUnescaped`/`splitKeyValue`
helpers live in `normalization/escaping.dart` and are used by both
`WifiParser` and `ContactParser`/`CalendarParser`.

## Stable content identity

`ContentIdentity` (`identity/content_identity.dart`) is `{ kind, value }`,
where `value` is a hex digest — **never the raw or normalized value
itself**. `buildContentIdentity` (`identity/content_identity_builder.dart`)
computes it per kind; general rules that hold for every kind:

- identity never depends on `capturedAt` or `source`;
- identity is hashed, not reversible — nothing downstream can recover the
  original content from an identity alone;
- "safe" normalization can collapse into one identity (e.g. scheme/host
  casing), but materially different content must not.

### Hashing

`_stableHash` is a from-scratch 64-bit digest: two 32-bit FNV-1a passes
with different seeds over the UTF-8 bytes, concatenated to a 16-hex-char
string. Deliberately **not** `String.hashCode` — Dart does not guarantee
that's stable across SDK versions or platforms, which would silently
break identity comparisons persisted by a future milestone. Not
cryptographic; this exists for duplicate-content recognition, not
security. The arithmetic assumes 64-bit integers (true on the Dart
VM/AOT target this Android-only app ships on) and would need revisiting
if ever compiled to JavaScript.

### Per-kind identity key

| Kind | Key | Rationale |
|---|---|---|
| URL | The normalized URL string | Single source of truth shared with display |
| Wi-Fi | `ssid + securityType + isHidden + hasPassword` | **Deliberately excludes the password value itself** — identity reflects "the same network configuration", not "the same password". If a network's password changes but SSID/security/hidden stay the same, ScanWise still treats it as the same network. This is a documented limitation, not an oversight: revisit if finer-grained duplicate tracking becomes a product need |
| Contact | Conservative: normalized name + first phone/email if either is present; falls back to a `name-only:` key (still requires an exact name match) when neither exists | Two different people sharing a name and phone number is vanishingly rare; two contacts sharing only a name are common and must **not** collide. This intentionally *under-merges* (a contact's phone number changing produces a new identity) rather than risk merging two different people |
| Product | `symbology + digits` | Two GTINs on different symbologies with coincidentally equal digits are extremely unlikely, but this keeps them independent anyway |
| ISBN | Canonical ISBN-13 form | Same book scanned as ISBN-10 or ISBN-13 resolves to one identity |
| Plain text | The raw text itself | Matches the identity-transform normalization rule |
| Email / phone / sms / location / calendarEvent / unknown | The kind's `normalizedValue` | No stronger canonicalization is safe to apply yet; documented as the simplest correct default |

### Documented limitations

- Wi-Fi identity ignores password content (see table above).
- Contact identity is conservative by design — it will treat two scans of
  the *same physical business card* as different identities if, say, a
  phone number was corrected between scans. This is intentional: silently
  merging two different people because they share a name is worse.
- Hashing is not cryptographic and not intended to resist deliberate
  collision construction — it exists purely for local duplicate
  recognition, which Milestone 003 does not yet act on (no persistence
  exists yet; that's the point where this identity becomes load-bearing).
- No persistence duplicate *behavior* (surfacing "you scanned this
  before") is implemented in this milestone — `ContentIdentity` is
  produced and tested, but nothing yet reads it back.
