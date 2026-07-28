/// Builds the normalized form of plain text content.
///
/// Documented rule: the identity transform. Plain text has no canonical
/// form the app can safely infer (case, whitespace and punctuation can
/// all carry meaning), so [normalizePlainText] returns [raw] unchanged —
/// see docs/engineering/normalization-and-identity.md. The only thing
/// content identity does beyond this is hash it.
String normalizePlainText(String raw) => raw;
