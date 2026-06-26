import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AvistamientoResumen {
  const AvistamientoResumen({
    required this.distanciaKm,
    required this.haceMinutos,
  });

  final double distanciaKm;
  final int haceMinutos;

  factory AvistamientoResumen.fromMap(Map<String, dynamic> map) {
    return AvistamientoResumen(
      distanciaKm: (map['distancia_km'] as num).toDouble(),
      haceMinutos: map['hace_minutos'] as int,
    );
  }

  String get texto {
    final tiempo = haceMinutos < 1
        ? 'hace un momento'
        : haceMinutos == 1
            ? 'hace 1 min'
            : 'hace $haceMinutos min';
    return 'Avistamiento a ${distanciaKm.toStringAsFixed(1)} km · $tiempo';
  }
}

/// Registro de avistamientos «Lo vi» (Sprint 3+).
class AvistamientoService {
  AvistamientoService._();

  static Future<String> registrarLoVi(
    String alertaId, {
    double? lat,
    double? lng,
  }) async {
    final id = await SupabaseService.client.rpc<dynamic>(
      'registrar_avistamiento',
      params: {
        'p_alerta_id': alertaId,
        'p_lat': lat,
        'p_lng': lng,
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
