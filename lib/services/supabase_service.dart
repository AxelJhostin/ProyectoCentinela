import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_env.dart';

/// Inicialización y operaciones de Supabase para Centinela (proyecto centinela-mvp).
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      publishableKey: AppEnv.supabasePublishableKey,
    );
  }

  /// Sprint 0 — prueba de conexión: login anónimo + lectura de tablas.
  /// Requiere "Anonymous sign-ins" activo en Supabase Auth.
  static Future<String> runConnectionTest() async {
    final auth = client.auth;

    if (auth.currentSession == null) {
      await auth.signInAnonymously();
    }

    final userId = auth.currentUser?.id;
    if (userId == null) {
      throw StateError('No se pudo obtener sesión anónima.');
    }

    // Upsert perfil mínimo en usuarios (vinculado a auth.users).
    await client.from('usuarios').upsert({
      'auth_user_id': userId,
      'telefono_o_email': 'anon@test.centinela.local',
    }, onConflict: 'auth_user_id');

    final alertas = await client
        .from('alertas_desaparecidos')
        .select('id')
        .limit(1);

    final count = alertas.length;
    return 'Conexión OK · Usuario $userId · Alertas visibles: $count';
  }
}
