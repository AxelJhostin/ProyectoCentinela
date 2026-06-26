import 'supabase_service.dart';

/// Post-moderación: reportar alertas falsas (Sprint 3).
class ModeracionService {
  ModeracionService._();

  static Future<void> reportarAlertaFalsa(
    String alertaId, {
    String? motivo,
  }) async {
    await SupabaseService.client.rpc<void>(
      'reportar_alerta_falsa',
      params: {
        'p_alerta_id': alertaId,
        'p_motivo': motivo,
      },
    );
  }
}
