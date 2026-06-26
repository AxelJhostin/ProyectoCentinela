import 'package:flutter/material.dart';

import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Diálogo único: cómo ayudar como testigo (Sprint 6).
class WitnessGuideDialog extends StatelessWidget {
  const WitnessGuideDialog({super.key, required this.onDismiss});

  final Future<void> Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Cómo puedes ayudar?'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Bullet(
              icon: Icons.visibility_outlined,
              text: 'Si recibes una alerta y lo ves, pulsa **Lo vi** y marca dónde.',
            ),
            const SizedBox(height: CentinelaSpacing.md),
            _Bullet(
              icon: Icons.privacy_tip_outlined,
              text: 'No compartas datos personales del testigo ni del emisor.',
            ),
            const SizedBox(height: CentinelaSpacing.md),
            _Bullet(
              icon: Icons.share_outlined,
              text: 'Compartir por WhatsApp ayuda a quien no tiene la app instalada.',
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            await onDismiss();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: CentinelaColors.community, size: 22),
        const SizedBox(width: CentinelaSpacing.sm),
        Expanded(
          child: Text(
            text.replaceAll('**', ''),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
