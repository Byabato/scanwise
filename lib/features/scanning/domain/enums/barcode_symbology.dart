/// The barcode/QR symbology a scan was captured as, per the supported
/// formats in docs/product/v1-scope.md.
///
/// Parsers use this — not just the raw text shape — to decide whether a
/// bare numeric value is a product identifier. A QR code that happens to
/// contain "12345678" is ordinary text; an EAN-8 barcode with the same
/// digits is a product. See `ProductParser`/`IsbnParser`.
enum BarcodeSymbology {
  qrCode,
  ean8,
  ean13,
  upcA,
  upcE,
  code128,
  dataMatrix,
  pdf417,
  aztec,

  /// The capture source did not report a symbology (e.g. a directly
  /// constructed test candidate). Product/ISBN parsers decline for this
  /// value — see their `canParse` documentation.
  unknown,
}

/// Symbologies that are meaningfully "product barcodes" for the purposes of
/// [ProductPayload] classification. Kept next to the enum so every parser
/// consults the same list.
const Set<BarcodeSymbology> productSymbologies = {
  BarcodeSymbology.ean8,
  BarcodeSymbology.ean13,
  BarcodeSymbology.upcA,
  BarcodeSymbology.upcE,
};

/// A short, human-facing label — used to populate [ParsedScan.attributes]
/// without giving the domain layer any Flutter/presentation dependency.
extension BarcodeSymbologyLabel on BarcodeSymbology {
  String get label => switch (this) {
    BarcodeSymbology.qrCode => 'QR Code',
    BarcodeSymbology.ean8 => 'EAN-8',
    BarcodeSymbology.ean13 => 'EAN-13',
    BarcodeSymbology.upcA => 'UPC-A',
    BarcodeSymbology.upcE => 'UPC-E',
    BarcodeSymbology.code128 => 'Code 128',
    BarcodeSymbology.dataMatrix => 'Data Matrix',
    BarcodeSymbology.pdf417 => 'PDF417',
    BarcodeSymbology.aztec => 'Aztec',
    BarcodeSymbology.unknown => 'Unknown',
  };
}
