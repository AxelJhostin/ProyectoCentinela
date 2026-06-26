import 'package:flutter/material.dart';

import '../../models/alerta_desaparecido.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/centinela_action_button.dart';

/// Pantalla 3 — Detalle de alerta para el receptor (Sprint 1, mock actions).
class DetalleAlertaScreen extends StatelessWidget {
  const DetalleAlertaScreen({super.key, required this.alerta});

  final AlertaDesaparecido alerta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _PhotoHero(alerta: alerta),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(CentinelaSpacing.lg),
              children: [
                Text(
                  alerta.nombrePersona,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Edad aproximada: ${alerta.edadAprox} años',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'A ${alerta.distanciaKm.toStringAsFixed(1)} km de tu ubicación',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CentinelaColors.community,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: CentinelaSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(CentinelaSpacing.md),
                  decoration: BoxDecoration(
                    color: CentinelaColors.surface,
                    borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
                    border: Border.all(color: CentinelaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vestimenta',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: CentinelaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(alerta.vestimenta, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  CentinelaActionButton(
                    label: 'Compartir WhatsApp',
                    color: CentinelaColors.whatsApp,
                    icon: Icons.share,
                    onPressed: () => _mockAction(context, 'WhatsApp (Sprint 3)'),
                  ),
                  const SizedBox(width: 12),
                  CentinelaActionButton(
                    label: '¡Lo Vi!',
                    color: CentinelaColors.community,
                    icon: Icons.my_location,
                    onPressed: () => _mockAction(context, 'Avistamiento (Sprint 3)'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mockAction(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mock: $feature')),
    );
  }
}

class _PhotoHero extends StatelessWidget {
  const _PhotoHero({required this.alerta});

  final AlertaDesaparecido alerta;

  @override
  Widget build(BuildContext context) {
    final inicial = alerta.nombrePersona.isNotEmpty
        ? alerta.nombrePersona[0].toUpperCase()
        : '?';

    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          color: CentinelaColors.alertCritical.withValues(alpha: 0.15),
          alignment: Alignment.center,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: CentinelaColors.alertCritical.withValues(alpha: 0.25),
            child: Text(
              inicial,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: CentinelaColors.alertCritical,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: CentinelaSpacing.lg,
          bottom: CentinelaSpacing.lg,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CentinelaColors.alertCritical,
              borderRadius: BorderRadius.circular(CentinelaSpacing.radiusSm),
            ),
            child: const Text(
              'ALERTA ACTIVA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
