import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_service.dart';

/// Consentimiento legal LOPDP (Sprint 4).
class LegalService {
  LegalService._();

  static const _key = 'legal_consent_v1';

  static Future<bool> hasLocalConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    await SupabaseService.client.rpc<void>('registrar_consentimiento_lopdp');
  }
}
