import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/alerta_desaparecido.dart';
import 'cache_service.dart';
import 'location_service.dart';
import 'supabase_service.dart';

/// CRUD de alertas contra Supabase (Sprint 2+).
class AlertaService {
  AlertaService._();

  static SupabaseClient get _client => SupabaseService.client;

  static bool _usandoCache = false;
  static DateTime? _cacheGuardadoEn;

  static bool get usandoCache => _usandoCache;
  static DateTime? get cacheGuardadoEn => _cacheGuardadoEn;

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
    _usandoCache = false;
    _cacheGuardadoEn = null;

    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        userLat = pos.latitude;
        userLng = pos.longitude;
      }

      final rows = await _client.from('v_alertas_activas').select();
      final list = (rows as List).cast<Map<String, dynamic>>();
      final alertas = list
          .map((r) => AlertaDesaparecido.fromMap(r, userLat: userLat, userLng: userLng))
          .toList();
      alertas.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));

      await CacheService.guardarAlertasActivas(alertas);
      return alertas;
    } catch (_) {
      final cache = await CacheService.leerAlertasActivas();
      if (cache != null && cache.alertas.isNotEmpty) {
        _usandoCache = true;
        _cacheGuardadoEn = cache.guardadoEn;
        return cache.alertas;
      }
      rethrow;
    }
  }

  static Future<List<AlertaDesaparecido>> fetchHistorialCercano({
    required double lat,
    required double lng,
    int radioKm = 50,
  }) async {
    final json = await _client.rpc<dynamic>(
      'listar_historial_cercano',
      params: {'p_lat': lat, 'p_lng': lng, 'p_radio_km': radioKm},
    );
    if (json == null) return [];
    return _parseAlertaList(json, userLat: lat, userLng: lng);
  }

  static Future<List<AlertaDesaparecido>> fetchMiHistorial() async {
    final json = await _client.rpc<dynamic>('listar_mi_historial');
    if (json == null) return [];
    return _parseAlertaList(json);
  }

  static List<AlertaDesaparecido> _parseAlertaList(
    dynamic json, {
    double? userLat,
    double? userLng,
  }) {
    final list = json as List;
    return list
        .map((e) => AlertaDesaparecido.fromMap(
              Map<String, dynamic>.from(e as Map),
              userLat: userLat,
              userLng: userLng,
            ))
        .toList();
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
    int radioKm = 10,
    String? ultimaVistaTexto,
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
        'p_ultima_vista_texto': ultimaVistaTexto,
      },
    );
    return id.toString();
  }

  static Future<void> resolverAlerta(String alertaId) async {
    await _client.rpc<void>('resolver_alerta', params: {'p_alerta_id': alertaId});
  }

  static Future<String?> miAlertaActivaId() async {
    final miId = await currentUsuarioId;
    if (miId == null) return null;
    final row = await _client
        .from('alertas_desaparecidos')
        .select('id')
        .eq('emisor_id', miId)
        .eq('estado', 'ACTIVA')
        .maybeSingle();
    return row?['id'] as String?;
  }

  static Future<AlertaDesaparecido?> fetchById(
    String alertaId, {
    double? userLat,
    double? userLng,
  }) async {
    try {
      final json = await _client.rpc<dynamic>(
        'obtener_alerta',
        params: {'p_alerta_id': alertaId},
      );
      if (json == null) return null;
      final map = Map<String, dynamic>.from(json as Map);
      final alerta = AlertaDesaparecido.fromMap(map, userLat: userLat, userLng: userLng);
      await CacheService.guardarDetalle(alerta);
      return alerta;
    } catch (_) {
      final cached = await CacheService.leerDetalle();
      if (cached != null && cached.id == alertaId) return cached;
      return null;
    }
  }
}
