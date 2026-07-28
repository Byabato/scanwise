/// Builds the normalized form of a phone number.
///
/// Documented rule: strip formatting punctuation (spaces, hyphens,
/// parentheses, dots) and preserve a single leading `+` if present. Does
/// not validate, infer, or add a country code, and performs no
/// country-specific reformatting — see
/// docs/engineering/normalization-and-identity.md.
String normalizePhoneNumber(String raw) {
  final trimmed = raw.trim();
  final hasLeadingPlus = trimmed.startsWith('+');
  final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  return hasLeadingPlus ? '+$digitsOnly' : digitsOnly;
}
