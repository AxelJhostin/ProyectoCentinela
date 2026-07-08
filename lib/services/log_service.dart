import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

/// Logs centralizados vía RPC (Sprint 9).
class LogService {
  LogService._();

  static Future<void> registrar({
    required String nivel,
    required String origen,
    required String evento,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await SupabaseService.client.rpc<void>(
        'registrar_log',
        params: {
          'p_nivel': nivel,
          'p_origen': origen,
          'p_evento': evento,
          'p_payload': payload,
        },
      );
    } catch (e) {
      debugPrint('Log no registrado: $e');
    }
  }
}
