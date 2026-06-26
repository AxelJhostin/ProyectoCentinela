import 'package:flutter/material.dart';

import '../theme/centinela_theme.dart';

/// FAB rojo del wireframe — emitir alerta.
class EmitirAlertaFab extends StatelessWidget {
  const EmitirAlertaFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.large(
          onPressed: onPressed,
          elevation: 4,
          child: const Icon(Icons.campaign, size: 32),
        ),
        const SizedBox(height: 4),
        Text(
          'Alerta',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: CentinelaColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
