import 'package:flutter/material.dart';

import '../theme/centinela_spacing.dart';

/// Botones de acción del detalle (WhatsApp / Lo vi).
class CentinelaActionButton extends StatelessWidget {
  const CentinelaActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
          ),
        ),
        icon: Icon(icon ?? Icons.touch_app, size: 20),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
