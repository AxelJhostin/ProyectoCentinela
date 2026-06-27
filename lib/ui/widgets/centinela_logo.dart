import 'package:flutter/material.dart';

import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Marca Centinela — logo + nombre + tagline (Sprint 7).
class CentinelaLogo extends StatelessWidget {
  const CentinelaLogo({
    super.key,
    this.iconSize = 88,
    this.showTagline = true,
  });

  final double iconSize;
  final bool showTagline;

  static const tagline = 'Alertas de tu comunidad, cerca de ti.';

  /// Logo horizontal para AppBar (Sprint 8).
  static Widget compact({double iconSize = 32}) {
    return CentinelaLogoCompact(iconSize: iconSize);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize * 0.22),
          child: Image.asset(
            'assets/brand/app_icon.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: CentinelaSpacing.lg),
        Text(
          'Centinela',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: CentinelaColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        if (showTagline) ...[
          const SizedBox(height: CentinelaSpacing.sm),
          Text(
            tagline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CentinelaColors.community,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Marca compacta — icono + nombre para AppBar.
class CentinelaLogoCompact extends StatelessWidget {
  const CentinelaLogoCompact({super.key, this.iconSize = 32});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize * 0.22),
          child: Image.asset(
            'assets/brand/app_icon.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Centinela',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: CentinelaColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
