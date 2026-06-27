import 'package:flutter/material.dart';

import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// FAB principal — emitir alerta (Sprint 8: más visible y claro).
class EmitirAlertaFab extends StatelessWidget {
  const EmitirAlertaFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: CentinelaColors.alertCritical.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
      color: CentinelaColors.alertCritical,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Emitir alerta',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Reportar desaparición',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
