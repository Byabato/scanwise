/// How a scan's raw value was captured, per the two capture paths in
/// docs/product/v1-scope.md. Does not affect parsing outcome, only display
/// and analytics-free bookkeeping.
enum ScanSource { camera, gallery }

/// A short, human-facing label — used to populate [ParsedScan.attributes]
/// without giving the domain layer any Flutter/presentation dependency.
extension ScanSourceLabel on ScanSource {
  String get label => switch (this) {
    ScanSource.camera => 'Camera',
    ScanSource.gallery => 'Gallery',
  };
}
