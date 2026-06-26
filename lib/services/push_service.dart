import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

/// Invoca Edge Functions FCM (Sprint 5.2).
class PushService {
  PushService._();

  static Future<void> notificarUsuariosCercanos({
    required String alertaId,
    required double lat,
    required double lng,
    required String nombrePersona,
    int radioKm = 10,
  }) async {
    try {
      final res = await SupabaseService.client.functions.invoke(
        'dispatch-alert-push',
        body: {
          'alerta_id': alertaId,
          'lat': lat,
          'lng': lng,
          'radio_km': radioKm,
          'nombre_persona': nombrePersona,
        },
      );
      debugPrint('Push comunidad: ${res.data}');
    } catch (e) {
      debugPrint('Push comunidad no enviado: $e');
    }
  }

  static Future<void> notificarEmisorAvistamiento(String alertaId) async {
    try {
      final res = await SupabaseService.client.functions.invoke(
        'dispatch-avistamiento-push',
        body: {'alerta_id': alertaId},
      );
      debugPrint('Push emisor avistamiento: ${res.data}');
    } catch (e) {
      debugPrint('Push emisor no enviado: $e');
    }
  }
}
