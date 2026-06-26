import 'package:latlong2/latlong.dart';

/// Punto elegido en mapa + etiqueta opcional (búsqueda o GPS).
class UbicacionSeleccion {
  const UbicacionSeleccion({
    required this.point,
    this.etiquetaLugar,
  });

  final LatLng point;
  final String? etiquetaLugar;
}
