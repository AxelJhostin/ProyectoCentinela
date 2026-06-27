import 'package:url_launcher/url_launcher.dart';

/// Abrir ubicaciones en Google Maps (avistamientos, puntos de búsqueda).
class MapsService {
  MapsService._();

  /// Punto donde alguien reportó «Lo vi» — para que familia/emisor vayan a buscar.
  static Future<bool> abrirAvistamiento({
    required double lat,
    required double lng,
    String? etiqueta,
  }) async {
    final label = etiqueta?.trim();
    final coords = '$lat,$lng';
    final query = (label != null && label.isNotEmpty)
        ? Uri.encodeComponent('$label ($coords)')
        : coords;

    final uris = [
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
      Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
      Uri.parse('https://maps.google.com/?q=$lat,$lng'),
    ];

    for (final uri in uris) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }
}
