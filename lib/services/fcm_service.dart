import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

/// Registro del token FCM en Supabase (Sprint 3).
/// Cuando configures Firebase, llama [init] desde el bootstrap.
class FcmService {
  FcmService._();

  static Future<void> init() async {
    // Firebase se activa al agregar google-services.json (ver Documentos/Firebase-Setup.md).
    debugPrint(
      'FCM: pendiente de Firebase. Sigue Documentos/Firebase-Setup.md para push real.',
    );
  }

  static Future<void> saveToken(String token) async {
    await SupabaseService.client.rpc<void>(
      'actualizar_fcm_token',
      params: {'p_token': token},
    );
  }
}
