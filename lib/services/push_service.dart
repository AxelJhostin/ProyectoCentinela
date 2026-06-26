import 'package:flutter/foundation.dart';

import '../models/push_dispatch_result.dart';
import 'supabase_service.dart';

/// Invoca Edge Functions FCM (Sprint 5.2+).
class PushService {
  PushService._();

  static Future<PushDispatchResult> notificarUsuariosCercanos({
    required String alertaId,
    required double lat,
    required double lng,
    required String nombrePersona,
    required int radioKm,
    int? edadAprox,
    String? ultimaVistaTexto,
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
          'edad_aprox': ?edadAprox,
          'ultima_vista_texto': ?ultimaVistaTexto,
        },
      );
      final result = PushDispatchResult.fromResponse(res.data);
      debugPrint('Push comunidad: ${res.data}');
      return result;
    } catch (e) {
      debugPrint('Push comunidad no enviado: $e');
      return PushDispatchResult(
        ok: false,
        sent: 0,
        total: 0,
        message: e.toString(),
      );
    }
  }

  static Future<void> notificarEmisorAvistamiento({
    required String alertaId,
    String? ubicacionTexto,
    double? distanciaKm,
    String? notaPreview,
  }) async {
    try {
      final res = await SupabaseService.client.functions.invoke(
        'dispatch-avistamiento-push',
        body: {
          'alerta_id': alertaId,
          'ubicacion_texto': ?ubicacionTexto,
          'distancia_km': ?distanciaKm,
          'nota_preview': ?notaPreview,
        },
      );
      debugPrint('Push emisor avistamiento: ${res.data}');
    } catch (e) {
      debugPrint('Push emisor no enviado: $e');
    }
  }

  static Future<PushDispatchResult> notificarComunidadResuelto({
    required String alertaId,
    required double lat,
    required double lng,
    required int radioKm,
    required String nombrePersona,
  }) async {
    try {
      final res = await SupabaseService.client.functions.invoke(
        'dispatch-resuelto-push',
        body: {
          'alerta_id': alertaId,
          'lat': lat,
          'lng': lng,
          'radio_km': radioKm,
          'nombre_persona': nombrePersona,
        },
      );
      final result = PushDispatchResult.fromResponse(res.data);
      debugPrint('Push resuelto: ${res.data}');
      return result;
    } catch (e) {
      debugPrint('Push resuelto no enviado: $e');
      return PushDispatchResult(
        ok: false,
        sent: 0,
        total: 0,
        message: e.toString(),
      );
    }
  }
}
