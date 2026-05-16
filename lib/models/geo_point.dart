/// Point géographique WGS84 (PostGIS GEOGRAPHY Point, SRID 4326).
class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  /// Parse le format GeoJSON renvoyé par Supabase/PostGIS.
  /// `{"type":"Point","coordinates":[longitude, latitude]}`
  /// Parse sans lever d'exception (retourne `null` si échec).
  static GeoPoint? tryParse(dynamic json) {
    if (json == null) return null;
    try {
      return GeoPoint.fromJson(json);
    } on Object {
      return null;
    }
  }

  factory GeoPoint.fromJson(dynamic json) {
    if (json == null) {
      throw ArgumentError('GeoPoint.fromJson: valeur nulle');
    }
    if (json is Map) {
      final coordinates = json['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        return GeoPoint(
          longitude: _toDouble(coordinates[0]),
          latitude: _toDouble(coordinates[1]),
        );
      }
    }
    if (json is String && json.startsWith('POINT')) {
      // WKT : POINT(lng lat)
      final inner = json.replaceAll('POINT(', '').replaceAll(')', '');
      final parts = inner.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return GeoPoint(
          longitude: double.parse(parts[0]),
          latitude: double.parse(parts[1]),
        );
      }
    }
    throw FormatException('Format GeoPoint non supporté: $json');
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  Map<String, dynamic> toJson() => {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
