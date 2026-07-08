import 'supabase_service.dart';

/// Panel admin vía RPCs (Sprint 10).
class AdminService {
  AdminService._();

  static Future<bool> esAdmin() async {
    try {
      final result = await SupabaseService.client.rpc<bool>('es_admin');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> listarAlertas({
    String? estado,
    int limite = 50,
  }) async {
    final json = await SupabaseService.client.rpc<dynamic>(
      'admin_listar_alertas',
      params: {'p_estado': estado, 'p_limite': limite},
    );
    if (json == null) return [];
    return (json as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> forzarEstado(String alertaId, String estado) async {
    await SupabaseService.client.rpc<void>(
      'admin_forzar_estado',
      params: {'p_alerta_id': alertaId, 'p_estado': estado},
    );
  }

  static Future<void> ajustarScore(String usuarioId, int score) async {
    await SupabaseService.client.rpc<void>(
      'admin_ajustar_score',
      params: {'p_usuario_id': usuarioId, 'p_score': score},
    );
  }
}
