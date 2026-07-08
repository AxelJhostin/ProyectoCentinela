import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Resultado de búsqueda de lugares (Nominatim / OpenStreetMap).
class GeocodingPlace {
  const GeocodingPlace({
    required this.displayName,
    required this.point,
  });

  final String displayName;
  final LatLng point;
}

/// Geocodificación gratuita para el piloto (sin API key).
class GeocodingService {
  GeocodingService._();

  static const _userAgent = 'CentinelaMVP/0.1 (com.axeljhostin.centinela.centinela)';

  /// Centro del piloto en Manabí (coordenadas de referencia para geocoding).
  static const LatLng jipijapaCenter = LatLng(-1.34885, -80.57934);

  static Future<List<GeocodingPlace>> search(
    String query, {
    LatLng? near,
  }) async {
    final q = query.trim();
    if (q.length < 3) return [];

    final anchor = near ?? jipijapaCenter;
    final list = await _fetch(
      q: q,
      anchor: anchor,
      bounded: true,
    );

    if (list.isEmpty) {
      return _fetch(q: q, anchor: anchor, bounded: false);
    }

    return list;
  }

  static Future<List<GeocodingPlace>> _fetch({
    required String q,
    required LatLng anchor,
    required bool bounded,
  }) async {
    final params = <String, String>{
      'q': q,
      'format': 'json',
      'limit': '6',
      'countrycodes': 'ec',
      'addressdetails': '0',
    };

    if (bounded) {
      params['viewbox'] =
          '${anchor.longitude - 0.45},${anchor.latitude + 0.45},'
          '${anchor.longitude + 0.45},${anchor.latitude - 0.45}';
      params['bounded'] = '1';
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);

    final res = await http.get(
      uri,
      headers: {'User-Agent': _userAgent},
    );

    if (res.statusCode != 200) {
      throw Exception('No se pudo buscar el lugar');
    }

    final rawList = jsonDecode(res.body) as List<dynamic>;
    return rawList.map((raw) {
      final item = raw as Map<String, dynamic>;
      return GeocodingPlace(
        displayName: item['display_name'] as String? ?? q,
        point: LatLng(
          double.parse(item['lat'] as String),
          double.parse(item['lon'] as String),
        ),
      );
    }).toList();
  }

  /// Nombre legible de coordenadas (geocodificación inversa).
  static Future<String?> reverseLabel(LatLng point) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'format': 'json',
      'zoom': '16',
      'addressdetails': '1',
    });

    final res = await http.get(uri, headers: {'User-Agent': _userAgent});
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;
    if (address != null) {
      final parts = <String>[
        if (address['road'] != null) address['road'] as String,
        if (address['suburb'] != null) address['suburb'] as String,
        if (address['city'] != null)
          address['city'] as String
        else if (address['town'] != null)
          address['town'] as String
        else if (address['village'] != null)
          address['village'] as String,
      ].where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.take(3).join(', ');
    }

    final display = data['display_name'] as String?;
    if (display == null) return null;
    return display.length > 80 ? '${display.substring(0, 77)}…' : display;
  }
}
