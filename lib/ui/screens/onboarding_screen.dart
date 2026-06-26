import 'package:flutter/material.dart';

import '../../services/location_service.dart';
import '../../services/onboarding_service.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import 'home_screen.dart';

/// Onboarding — permisos GPS y notificaciones (Sprint 2).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _finishing = false;

  Future<void> _requestLocation() async {
    final ok = await LocationService.requestPermission();
    if (ok) await LocationService.syncUbicacionToSupabase();
    setState(() => _locationGranted = ok);
  }

  Future<void> _requestNotifications() async {
    final ok = await NotificationPermissionService.request();
    setState(() => _notificationGranted = ok);
  }

  Future<void> _continuar() async {
    setState(() => _finishing = true);
    await OnboardingService.markCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CentinelaSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.shield, size: 72, color: CentinelaColors.alertCritical),
              const SizedBox(height: CentinelaSpacing.lg),
              Text(
                'Bienvenido a Centinela',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Para alertas hiperlocales necesitamos tu ubicación y '
                'permiso para enviarte notificaciones críticas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CentinelaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CentinelaSpacing.lg),
              _PermissionTile(
                icon: Icons.location_on_outlined,
                title: 'Ubicación',
                subtitle: _locationGranted
                    ? 'Permiso concedido'
                    : 'Para alertas cerca de ti y geofencing',
                granted: _locationGranted,
                onTap: _requestLocation,
              ),
              const SizedBox(height: CentinelaSpacing.md),
              _PermissionTile(
                icon: Icons.notifications_active_outlined,
                title: 'Notificaciones',
                subtitle: _notificationGranted
                    ? 'Permiso concedido'
                    : 'Para avisos de desaparición (Sprint 3: push)',
                granted: _notificationGranted,
                onTap: _requestNotifications,
              ),
              const Spacer(),
              FilledButton(
                onPressed: _finishing ? null : _continuar,
                child: Text(_finishing ? 'Entrando…' : 'Continuar a Centinela'),
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes continuar aunque no concedas todos los permisos ahora.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CentinelaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CentinelaColors.surface,
      borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
      child: ListTile(
        leading: Icon(icon, color: granted ? CentinelaColors.whatsApp : CentinelaColors.community),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: granted
            ? const Icon(Icons.check_circle, color: CentinelaColors.whatsApp)
            : TextButton(onPressed: onTap, child: const Text('Permitir')),
        onTap: granted ? null : onTap,
      ),
    );
  }
}
