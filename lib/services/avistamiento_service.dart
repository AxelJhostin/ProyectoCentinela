import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Registro de avistamientos «Lo vi» (Sprint 3+).
class AvistamientoService {
  AvistamientoService._();

  static Future<String> registrarLoVi(String alertaId) async {
    final id = await SupabaseService.client.rpc<dynamic>(
      'registrar_avistamiento',
      params: {'p_alerta_id': alertaId},
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
          event: PostgresChangeEvent.insert,
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
