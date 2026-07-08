import 'package:flutter/foundation.dart';

import 'alerta_service.dart';
import 'supabase_service.dart';

/// Registro de compartidos y push al emisor (Sprint 10).
class CompartirService {
  CompartirService._();

  static Future<int> registrarYNotificar(String alertaId) async {
    try {
      final total = await SupabaseService.client.rpc<int>(
        'registrar_compartir_alerta',
        params: {'p_alerta_id': alertaId, 'p_canal': 'whatsapp'},
      );

      final miId = await AlertaService.currentUsuarioId;
      final alerta = await AlertaService.fetchById(alertaId);
      if (alerta != null && miId != null && miId != alerta.emisorId) {
        await _notificarEmisor(alertaId);
      }

      return total;
    } catch (e) {
      debugPrint('registrar_compartir falló: $e');
      return 0;
    }
  }

  static Future<int> contar(String alertaId) async {
    try {
      return await SupabaseService.client.rpc<int>(
        'contar_compartidos_alerta',
        params: {'p_alerta_id': alertaId},
      );
    } catch (_) {
      return 0;
    }
  }

  static Future<void> _notificarEmisor(String alertaId) async {
    try {
      await SupabaseService.client.functions.invoke(
        'dispatch-share-push',
        body: {'alerta_id': alertaId},
      );
    } catch (e) {
      debugPrint('dispatch-share-push: $e');
    }
  }
}
