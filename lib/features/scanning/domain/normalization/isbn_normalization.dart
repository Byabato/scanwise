import 'product_identifier_normalization.dart';

/// Builds the normalized form of an ISBN.
///
/// Documented rule: always canonicalize to ISBN-13 (converting an ISBN-10
/// via the standard `978` Bookland prefix and a recomputed check digit),
/// so scanning the same book as either format resolves to one identity.
/// The originally-entered format is preserved separately on [IsbnPayload]
/// for display. See docs/engineering/normalization-and-identity.md.
String convertIsbn10ToIsbn13(String isbn10Digits9) {
  final base12 = '978$isbn10Digits9';
  final check = computeGtinCheckDigit(base12);
  return '$base12$check';
}

/// Validates an ISBN-10's check digit (the 10th character, digit or
/// `X`/`x` representing 10), per the standard modulus-11 algorithm.
bool isValidIsbn10CheckDigit(String isbn10) {
  if (isbn10.length != 10) return false;
  var sum = 0;
  for (var i = 0; i < 10; i++) {
    final char = isbn10[i];
    final digit = (char == 'X' || char == 'x') ? 10 : int.tryParse(char);
    if (digit == null) return false;
    sum += (10 - i) * digit;
  }
  return sum % 11 == 0;
}
