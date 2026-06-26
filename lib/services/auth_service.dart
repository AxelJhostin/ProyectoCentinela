import 'supabase_service.dart';

/// Sesión anónima y perfil en tabla usuarios.
class AuthService {
  AuthService._();

  static Future<void> ensureSession() async {
    final auth = SupabaseService.client.auth;
    if (auth.currentSession == null) {
      await auth.signInAnonymously();
    }
    await _ensureUsuarioProfile();
  }

  static Future<void> _ensureUsuarioProfile() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;

    await SupabaseService.client.from('usuarios').upsert({
      'auth_user_id': userId,
    }, onConflict: 'auth_user_id');
  }

  static String? get authUserId => SupabaseService.client.auth.currentUser?.id;
}
