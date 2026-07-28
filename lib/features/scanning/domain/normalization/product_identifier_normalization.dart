/// Builds the normalized form of a product barcode identifier.
///
/// Documented rule: trim surrounding whitespace only. Digits are kept
/// exactly as scanned, including leading zeros — a GTIN's leading zeros
/// are significant (e.g. a UPC-A stored as a 13-digit GTIN), so stripping
/// them would silently change the identifier's meaning. See
/// docs/engineering/normalization-and-identity.md.
String normalizeProductIdentifier(String raw) => raw.trim();

/// Computes the standard GTIN check digit for [twelveDigits] (the first
/// 12 digits of a 13-digit GTIN). Used directly for EAN-13, and for
/// EAN-8/UPC-A by left-padding to 12 digits first — padding with zeros
/// preserves the correct alternating weight pattern for every one of
/// those lengths, so one implementation covers all three. See
/// `ProductParser` and `isbn_normalization.dart`.
int computeGtinCheckDigit(String twelveDigits) {
  var sum = 0;
  for (var i = 0; i < twelveDigits.length; i++) {
    final digit = int.parse(twelveDigits[i]);
    final isOddPosition = (i + 1).isOdd;
    sum += digit * (isOddPosition ? 1 : 3);
  }
  return (10 - (sum % 10)) % 10;
}

/// Validates a GTIN-8/12/13-shaped digit string's trailing check digit
/// against [computeGtinCheckDigit], after left-padding to 13 digits.
/// Returns false for anything that isn't purely digits of length 8, 12 or
/// 13.
bool isValidGtinCheckDigit(String digits) {
  if (digits.length != 8 && digits.length != 12 && digits.length != 13) {
    return false;
  }
  if (!RegExp(r'^\d+$').hasMatch(digits)) return false;

  final padded = digits.padLeft(13, '0');
  final expected = computeGtinCheckDigit(padded.substring(0, 12));
  final actual = int.parse(padded.substring(12));
  return expected == actual;
}
