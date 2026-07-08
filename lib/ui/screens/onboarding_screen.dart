import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/legal_service.dart';
import '../../services/location_service.dart';
import '../../services/onboarding_service.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/centinela_logo.dart';
import 'home_screen.dart';

/// Onboarding — permisos + guía contextual (Sprint 8).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _legalAccepted = false;
  bool _finishing = false;

  static const _tips = [
    (
      icon: Icons.notifications_active_outlined,
      title: 'Alertas push',
      body: 'Si recibes una notificación roja, tócala para ver el detalle '
          'de la persona desaparecida cerca de ti.',
    ),
    (
      icon: Icons.visibility_outlined,
      title: 'Reportar «Lo vi»',
      body: 'Puedes ayudar marcando dónde viste a la persona. '
          'Tu teléfono nunca se comparte con el emisor.',
    ),
    (
      icon: Icons.sos_outlined,
      title: 'Emitir alerta',
      body: 'El botón rojo del mapa permite reportar una desaparición '
          'a tu comunidad en segundos.',
    ),
  ];

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
    if (!_legalAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y la política de privacidad'),
        ),
      );
      return;
    }

    setState(() => _finishing = true);
    try {
      await LegalService.acceptTerms();
      await OnboardingService.markCompleted();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
      await initSprint3Services();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _finishing = false);
    }
  }

  void _siguientePagina() {
    if (_page < _tips.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  ..._tips.map(
                    (t) => _TipPage(
                      icon: t.icon,
                      title: t.title,
                      body: t.body,
                    ),
                  ),
                  _buildPermisosPage(context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(CentinelaSpacing.lg),
              child: _page < _tips.length
                  ? FilledButton(
                      onPressed: _siguientePagina,
                      child: Text(_page == _tips.length - 1
                          ? 'Configurar permisos'
                          : 'Siguiente'),
                    )
                  : FilledButton(
                      onPressed: (_finishing || !_legalAccepted) ? null : _continuar,
                      child: Text(_finishing ? 'Entrando…' : 'Continuar a Centinela'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermisosPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CentinelaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const CentinelaLogo(),
          const SizedBox(height: CentinelaSpacing.lg),
          Text(
            'Para alertas hiperlocales necesitamos tu ubicación y '
            'permiso para enviarte notificaciones.',
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
                : 'Para avisos de desaparición en tu zona',
            granted: _notificationGranted,
            onTap: _requestNotifications,
          ),
          const SizedBox(height: CentinelaSpacing.md),
          Material(
            color: CentinelaColors.surface,
            borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
                border: Border.all(
                  color: _legalAccepted
                      ? CentinelaColors.community.withValues(alpha: 0.4)
                      : CentinelaColors.border,
                ),
              ),
              child: CheckboxListTile(
                value: _legalAccepted,
                onChanged: _finishing
                    ? null
                    : (v) => setState(() => _legalAccepted = v ?? false),
                title: const Text(
                  'Acepto Términos y tratamiento de datos (LOPDP)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: TextButton(
                  onPressed: () async {
                    final ok = await LegalService.openPrivacyPolicyInBrowser();
                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir la política de privacidad'),
                        ),
                      );
                    }
                  },
                  child: const Text('Leer política de privacidad'),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Puedes continuar aunque no concedas todos los permisos ahora.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: CentinelaColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TipPage extends StatelessWidget {
  const _TipPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CentinelaSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CentinelaLogo(),
          const SizedBox(height: CentinelaSpacing.lg),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: CentinelaColors.community.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: CentinelaColors.community),
          ),
          const SizedBox(height: CentinelaSpacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: CentinelaSpacing.md),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: CentinelaColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
          border: Border.all(
            color: granted
                ? CentinelaColors.whatsApp.withValues(alpha: 0.4)
                : CentinelaColors.border,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (granted ? CentinelaColors.whatsApp : CentinelaColors.community)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: granted ? CentinelaColors.whatsApp : CentinelaColors.community,
            ),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: granted
              ? const Icon(Icons.check_circle, color: CentinelaColors.whatsApp)
              : FilledButton.tonal(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: CentinelaColors.community.withValues(alpha: 0.12),
                    foregroundColor: CentinelaColors.community,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('Permitir'),
                ),
          onTap: granted ? null : onTap,
        ),
      ),
    );
  }
}
