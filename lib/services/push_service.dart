import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

/// Invoca la Edge Function que envía push FCM a usuarios en radio (Sprint 3).
/// Requiere FCM_SERVER_KEY en Supabase Secrets y tokens en usuarios.fcm_token.
class PushService {
  PushService._();

  static Future<void> notificarUsuariosCercanos({
    required String alertaId,
    required double lat,
    required double lng,
    required String nombrePersona,
    int radioKm = 5,
  }) async {
    try {
      await SupabaseService.client.functions.invoke(
        'dispatch-alert-push',
        body: {
          'alerta_id': alertaId,
          'lat': lat,
          'lng': lng,
          'radio_km': radioKm,
          'nombre_persona': nombrePersona,
        },
      );
    } catch (e) {
      debugPrint('Push no enviado (FCM puede no estar configurado): $e');
    }
  }
}
