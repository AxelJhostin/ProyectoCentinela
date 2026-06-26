import 'package:flutter/material.dart';

import 'config/app_env.dart';
import 'services/supabase_service.dart';
import 'ui/screens/bootstrap_screen.dart';
import 'ui/theme/centinela_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  await SupabaseService.initialize();
  runApp(const CentinelaApp());
}

class CentinelaApp extends StatelessWidget {
  const CentinelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centinela',
      debugShowCheckedModeBanner: false,
      theme: buildCentinelaTheme(),
      home: const BootstrapScreen(),
    );
  }
}
