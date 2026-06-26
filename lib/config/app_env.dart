import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Variables de entorno cargadas desde `.env.local` (no se sube a GitHub).
class AppEnv {
  static Future<void> load() async {
    await dotenv.load(fileName: 'env/app.env');
  }

  static String get supabaseUrl {
    final value = dotenv.env['CENTINELA_SUPABASE_URL'];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Falta CENTINELA_SUPABASE_URL en env/app.env. Copia desde env/app.env.example.',
      );
    }
    return value;
  }

  static String get supabasePublishableKey {
    final value = dotenv.env['CENTINELA_SUPABASE_PUBLISHABLE_KEY'];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Falta CENTINELA_SUPABASE_PUBLISHABLE_KEY en env/app.env.',
      );
    }
    return value;
  }

  /// URL pública para preview WhatsApp (Edge Function alerta-preview).
  static String alertaPreviewUrl(String alertaId) =>
      '$supabaseUrl/functions/v1/alerta-preview?id=$alertaId';
}
