import 'supabase_service.dart';

/// Registro de avistamientos «Lo vi» (Sprint 3).
class AvistamientoService {
  AvistamientoService._();

  static Future<String> registrarLoVi(String alertaId) async {
    final id = await SupabaseService.client.rpc<dynamic>(
      'registrar_avistamiento',
      params: {'p_alerta_id': alertaId},
    );
    return id.toString();
  }
}
