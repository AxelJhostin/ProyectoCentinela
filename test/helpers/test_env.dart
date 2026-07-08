import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Carga variables de entorno mínimas para tests que usan AppEnv.
Future<void> loadTestEnv() async {
  dotenv.testLoad(
    fileInput: '''
CENTINELA_SUPABASE_URL=https://test-project.supabase.co
CENTINELA_SUPABASE_PUBLISHABLE_KEY=sb_publishable_test_key
CENTINELA_SUPABASE_PROJECT_REF=test-project
''',
  );
}
