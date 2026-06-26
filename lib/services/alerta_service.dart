import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/alerta_desaparecido.dart';
import 'supabase_service.dart';

/// CRUD de alertas contra Supabase (Sprint 2).
class AlertaService {
  AlertaService._();

  static SupabaseClient get _client => SupabaseService.client;

  static Future<String?> get currentUsuarioId async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) return null;
    final row = await _client
        .from('usuarios')
        .select('id')
        .eq('auth_user_id', authId)
        .maybeSingle();
    return row?['id'] as String?;
  }

  static Future<List<AlertaDesaparecido>> fetchActivas({
    double? userLat,
    double? userLng,
  }) async {
    final rows = await _client.from('v_alertas_activas').select();
    final list = (rows as List).cast<Map<String, dynamic>>();
    final alertas = list
        .map((r) => AlertaDesaparecido.fromMap(r, userLat: userLat, userLng: userLng))
        .toList();
    alertas.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));
    return alertas;
  }

  /// Realtime: emite lista actualizada cuando cambia alertas_desaparecidos.
  static Stream<List<AlertaDesaparecido>> watchActivas({
    required double? userLat,
    required double? userLng,
  }) {
    final controller = StreamController<List<AlertaDesaparecido>>();

    Future<void> emitLatest() async {
      try {
        final data = await fetchActivas(userLat: userLat, userLng: userLng);
        if (!controller.isClosed) controller.add(data);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    emitLatest();

    final channel = _client
        .channel('centinela_alertas_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'alertas_desaparecidos',
          callback: (_) => emitLatest(),
        )
        .subscribe();

    controller.onCancel = () async {
      await _client.removeChannel(channel);
    };

    return controller.stream;
  }

  static Future<String> crearAlerta({
    required String nombrePersona,
    required int edadAprox,
    required String vestimenta,
    required String fotoUrl,
    required double lat,
    required double lng,
    int radioKm = 5,
  }) async {
    final id = await _client.rpc<dynamic>(
      'crear_alerta_desaparecido',
      params: {
        'p_nombre_persona': nombrePersona,
        'p_edad_aprox': edadAprox,
        'p_vestimenta': vestimenta,
        'p_foto_url': fotoUrl,
        'p_lat': lat,
        'p_lng': lng,
        'p_radio_km': radioKm,
      },
    );
    return id.toString();
  }

  static Future<void> resolverAlerta(String alertaId) async {
    await _client.rpc<void>('resolver_alerta', params: {'p_alerta_id': alertaId});
  }
}
