import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/alerta_desaparecido.dart';

/// Cache local para modo offline parcial (Sprint 9).
class CacheService {
  CacheService._();

  static const _keyAlertas = 'cache_alertas_activas_v1';
  static const _keyAlertasTs = 'cache_alertas_ts_v1';
  static const _keyDetalle = 'cache_detalle_alerta_v1';

  static Future<void> guardarAlertasActivas(List<AlertaDesaparecido> alertas) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = alertas.map(_alertaToJson).toList();
    await prefs.setString(_keyAlertas, jsonEncode(jsonList));
    await prefs.setInt(_keyAlertasTs, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<({List<AlertaDesaparecido> alertas, DateTime? guardadoEn})?>
      leerAlertasActivas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAlertas);
    final ts = prefs.getInt(_keyAlertasTs);
    if (raw == null) return null;

    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return (
      alertas: list.map(_alertaFromJson).toList(),
      guardadoEn: ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null,
    );
  }

  static Future<void> guardarDetalle(AlertaDesaparecido alerta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDetalle, jsonEncode(_alertaToJson(alerta)));
  }

  static Future<AlertaDesaparecido?> leerDetalle() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDetalle);
    if (raw == null) return null;
    return _alertaFromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  static Map<String, dynamic> _alertaToJson(AlertaDesaparecido a) => {
        'id': a.id,
        'emisor_id': a.emisorId,
        'nombre_persona': a.nombrePersona,
        'edad_aprox': a.edadAprox,
        'vestimenta': a.vestimenta,
        'ultima_vista_texto': a.ultimaVistaTexto,
        'distancia_km': a.distanciaKm,
        'minutos_reportada': a.minutosReportada,
        'lat': a.latitud,
        'lng': a.longitud,
        'foto_url': a.fotoUrl,
        'radio_km': a.radioKm,
        'creado_en': a.creadoEn.toUtc().toIso8601String(),
        'estado': a.estado,
      };

  static AlertaDesaparecido _alertaFromJson(Map<String, dynamic> m) {
    return AlertaDesaparecido(
      id: m['id'] as String,
      emisorId: m['emisor_id'] as String,
      nombrePersona: m['nombre_persona'] as String,
      edadAprox: m['edad_aprox'] as int,
      vestimenta: (m['vestimenta'] as String?) ?? '',
      ultimaVistaTexto: (m['ultima_vista_texto'] as String?) ?? '',
      distanciaKm: (m['distancia_km'] as num?)?.toDouble() ?? 0,
      minutosReportada: m['minutos_reportada'] as int? ?? 0,
      latitud: (m['lat'] as num).toDouble(),
      longitud: (m['lng'] as num).toDouble(),
      fotoUrl: m['foto_url'] as String,
      radioKm: m['radio_km'] as int,
      creadoEn: DateTime.parse(m['creado_en'] as String).toLocal(),
      estado: (m['estado'] as String?) ?? 'ACTIVA',
    );
  }
}
