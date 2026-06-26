import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/onboarding_service.dart';
import '../theme/centinela_theme.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// Arranque: auth + onboarding + sync ubicación.
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await AuthService.ensureSession();
      final onboardingDone = await OnboardingService.isCompleted();

      if (!mounted) return;

      if (!onboardingDone) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
        );
        return;
      }

      await LocationService.syncUbicacionToSupabase();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
      await initSprint3Services();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  String? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: CentinelaColors.alertCritical),
                const SizedBox(height: 16),
                Text('Error al iniciar: $_error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: _bootstrap, child: const Text('Reintentar')),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: CentinelaColors.alertCritical),
            SizedBox(height: 16),
            Text('Iniciando Centinela…'),
          ],
        ),
      ),
    );
  }
}
