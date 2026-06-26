import 'package:flutter/material.dart';

import 'config/app_env.dart';
import 'services/deep_link_service.dart';
import 'services/fcm_service.dart';
import 'services/supabase_service.dart';
import 'ui/screens/bootstrap_screen.dart';
import 'ui/theme/centinela_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: navigatorKey,
      theme: buildCentinelaTheme(),
      home: const BootstrapScreen(),
    );
  }
}

/// Inicializa servicios de Sprint 3 tras el arranque (deep links + FCM stub).
Future<void> initSprint3Services() async {
  await FcmService.init();
  await DeepLinkService.init(navigatorKey);
}
