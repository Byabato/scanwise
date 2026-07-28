/// The maximum accepted length, in UTF-16 code units, of a
/// [ScanCandidate.rawValue].
///
/// Chosen well above any realistic QR/barcode payload — the densest
/// widely-used symbology here (PDF417) tops out in the low thousands of
/// characters at typical error-correction levels, and vCards with an
/// embedded photo are the only common payload that could approach this —
/// while still bounding worst-case parsing cost (regex/string-scan work
/// below is effectively O(n)) against a maliciously or accidentally huge
/// decoded value. See docs/engineering/parsing-strategy.md for the
/// oversized-input policy this constant gates.
const int kMaxScanContentLength = 8192;
