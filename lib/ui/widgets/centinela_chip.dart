import 'package:flutter/material.dart';

import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Badge compacto para distancia, tiempo o contadores.
class CentinelaChip extends StatelessWidget {
  const CentinelaChip({
    super.key,
    required this.label,
    this.icon,
    this.color = CentinelaColors.community,
    this.filled = true,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? color.withValues(alpha: 0.12) : Colors.transparent;
    final fg = filled ? color : CentinelaColors.textSecondary;
    final border = filled ? color.withValues(alpha: 0.25) : CentinelaColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusSm),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
