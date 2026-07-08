import 'package:latlong2/latlong.dart';

import '../utils/distancia_formato.dart';

/// Alerta de persona desaparecida (modelo de dominio MVP).
class AlertaDesaparecido {
  const AlertaDesaparecido({
    required this.id,
    required this.emisorId,
    required this.nombrePersona,
    required this.edadAprox,
    required this.vestimenta,
    required this.distanciaKm,
    required this.minutosReportada,
    required this.latitud,
    required this.longitud,
    required this.fotoUrl,
    required this.radioKm,
    required this.creadoEn,
    this.ultimaVistaTexto = '',
    this.estado = 'ACTIVA',
  });

  final String id;
  final String emisorId;
  final String nombrePersona;
  final int edadAprox;
  final String vestimenta;
  final String ultimaVistaTexto;
  final double distanciaKm;
  final int minutosReportada;
  final double latitud;
  final double longitud;
  final String fotoUrl;
  final int radioKm;
  final DateTime creadoEn;
  final String estado;

  String get distanciaTexto => DistanciaFormato.desdeUsuario(distanciaKm);

  String get tiempoTexto {
    if (estado != 'ACTIVA') {
      return estado == 'RESUELTA' ? 'Caso resuelto' : 'Alerta cerrada';
    }
    if (minutosReportada < 1) return 'Alerta activa · Hace un momento';
    if (minutosReportada == 1) return 'Alerta activa · Hace 1 min';
    return 'Alerta activa · Hace $minutosReportada min';
  }

  factory AlertaDesaparecido.fromMap(
    Map<String, dynamic> map, {
    double? userLat,
    double? userLng,
  }) {
    final lat = (map['lat'] as num).toDouble();
    final lng = (map['lng'] as num).toDouble();
    final creado = DateTime.parse(map['creado_en'] as String).toLocal();
    final minutos = DateTime.now().difference(creado).inMinutes;

    var distancia = (map['distancia_km'] as num?)?.toDouble() ?? 0.0;
    if (distancia == 0 && userLat != null && userLng != null) {
      distancia = const Distance().as(
        LengthUnit.Kilometer,
        LatLng(userLat, userLng),
        LatLng(lat, lng),
      );
    }

    return AlertaDesaparecido(
      id: map['id'] as String,
      emisorId: map['emisor_id'] as String,
      nombrePersona: map['nombre_persona'] as String,
      edadAprox: map['edad_aprox'] as int,
      vestimenta: (map['vestimenta'] as String?) ?? '',
      ultimaVistaTexto: (map['ultima_vista_texto'] as String?) ?? '',
      distanciaKm: distancia,
      minutosReportada: minutos,
      latitud: lat,
      longitud: lng,
      fotoUrl: map['foto_url'] as String,
      radioKm: map['radio_km'] as int,
      creadoEn: creado,
      estado: (map['estado'] as String?) ?? 'ACTIVA',
    );
  }
}
