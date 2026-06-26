import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AvistamientoResumen {
  const AvistamientoResumen({
    required this.distanciaKm,
    required this.haceMinutos,
    required this.lat,
    required this.lng,
    this.notaTestigo,
    this.ubicacionTexto,
    this.lugarResuelto,
  });

  final double distanciaKm;
  final int haceMinutos;
  final double lat;
  final double lng;
  final String? notaTestigo;
  final String? ubicacionTexto;
  final String? lugarResuelto;

  factory AvistamientoResumen.fromMap(Map<String, dynamic> map) {
    return AvistamientoResumen(
      distanciaKm: (map['distancia_km'] as num).toDouble(),
      haceMinutos: map['hace_minutos'] as int,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      notaTestigo: map['nota_testigo'] as String?,
      ubicacionTexto: map['ubicacion_texto'] as String?,
    );
  }

  AvistamientoResumen copyWith({String? lugarResuelto}) {
    return AvistamientoResumen(
      distanciaKm: distanciaKm,
      haceMinutos: haceMinutos,
      lat: lat,
      lng: lng,
      notaTestigo: notaTestigo,
      ubicacionTexto: ubicacionTexto,
      lugarResuelto: lugarResuelto,
    );
  }

  String get lugarDisplay {
    if (ubicacionTexto != null && ubicacionTexto!.isNotEmpty) {
      return _shorten(ubicacionTexto!);
    }
    if (lugarResuelto != null && lugarResuelto!.isNotEmpty) {
      return _shorten(lugarResuelto!);
    }
    return 'Lat ${lat.toStringAsFixed(4)}, Lng ${lng.toStringAsFixed(4)}';
  }

  String get tiempoTexto {
    if (haceMinutos < 1) return 'hace un momento';
    if (haceMinutos == 1) return 'hace 1 min';
    return 'hace $haceMinutos min';
  }

  String get lineaPrincipal =>
      'Visto cerca de: $lugarDisplay · ${distanciaKm.toStringAsFixed(1)} km de tu reporte · $tiempoTexto';

  static String _shorten(String text) {
    if (text.length <= 70) return text;
    return '${text.substring(0, 67)}…';
  }
}

/// Registro de avistamientos «Lo vi» (Sprint 3+).
class AvistamientoService {
  AvistamientoService._();

  static Future<String> registrarLoVi(
    String alertaId, {
    required double lat,
    required double lng,
    String? notaTestigo,
    String? ubicacionTexto,
  }) async {
    final id = await SupabaseService.client.rpc<dynamic>(
      'registrar_avistamiento',
      params: {
        'p_alerta_id': alertaId,
        'p_lat': lat,
        'p_lng': lng,
        'p_nota_testigo': notaTestigo,
        'p_ubicacion_texto': ubicacionTexto,
      },
    );
    return id.toString();
  }

  static Future<int> contar(String alertaId) async {
    final count = await SupabaseService.client.rpc<int>(
      'contar_avistamientos',
      params: {'p_alerta_id': alertaId},
    );
    return count;
  }

  static Future<List<AvistamientoResumen>> resumen(String alertaId) async {
    final json = await SupabaseService.client.rpc<dynamic>(
      'resumen_avistamientos',
      params: {'p_alerta_id': alertaId},
    );
    if (json == null) return [];
    final list = json as List;
    return list
        .map((e) => AvistamientoResumen.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Realtime: emite el total cuando alguien reporta «Lo vi».
  static Stream<int> watchCount(String alertaId) {
    final controller = StreamController<int>();

    Future<void> emitCount() async {
      try {
        final n = await contar(alertaId);
        if (!controller.isClosed) controller.add(n);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    emitCount();

    final channel = SupabaseService.client
        .channel('centinela_avistamientos_$alertaId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reacciones_avistamientos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'alerta_id',
            value: alertaId,
          ),
          callback: (_) => emitCount(),
        )
        .subscribe();

    controller.onCancel = () async {
      await SupabaseService.client.removeChannel(channel);
    };

    return controller.stream;
  }
}
