import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../../failures/scan_parse_failure.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Parses a `geo:` URI (RFC 5870): `geo:lat,lon[,alt][;params][?q=label]`.
///
/// Coordinates outside the valid range (±90 latitude, ±180 longitude) are
/// rejected outright — per the milestone contract, ScanWise never shows a
/// location result for an invalid one.
class LocationParser implements ScanPayloadParser {
  const LocationParser();

  @override
  bool canParse(ScanCandidate candidate) {
    return candidate.rawValue.trim().toLowerCase().startsWith('geo:');
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final value = candidate.rawValue.trim();
    final remainder = value.substring('geo:'.length);

    final queryIndex = remainder.indexOf('?');
    final coordinatePart = queryIndex == -1
        ? remainder
        : remainder.substring(0, queryIndex);
    String? query;
    if (queryIndex != -1) {
      final params = Uri.splitQueryString(remainder.substring(queryIndex + 1));
      query = params['q'];
    }

    final semicolonIndex = coordinatePart.indexOf(';');
    final cleanCoordinatePart = semicolonIndex == -1
        ? coordinatePart
        : coordinatePart.substring(0, semicolonIndex);
    final segments = cleanCoordinatePart.split(',');
    if (segments.length < 2) {
      return const ScanParseFailed(
        InvalidCoordinatesFailure('missing longitude'),
      );
    }

    final latitude = double.tryParse(segments[0].trim());
    final longitude = double.tryParse(segments[1].trim());
    if (latitude == null || longitude == null) {
      return const ScanParseFailed(
        InvalidCoordinatesFailure('non-numeric coordinates'),
      );
    }
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return const ScanParseFailed(
        InvalidCoordinatesFailure('coordinates out of range'),
      );
    }

    final normalizedQuery = (query == null || query.isEmpty) ? null : query;
    return ScanParseSuccess(
      kind: ScanKind.location,
      payload: LocationPayload(
        latitude: latitude,
        longitude: longitude,
        query: normalizedQuery,
      ),
      title:
          normalizedQuery ??
          '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
      normalizedValue:
          '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
    );
  }
}
