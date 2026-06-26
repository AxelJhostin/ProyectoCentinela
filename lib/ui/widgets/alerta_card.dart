import 'package:flutter/material.dart';

import '../../models/alerta_desaparecido.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Tarjeta de alerta en el bottom sheet del Home.
class AlertaCard extends StatelessWidget {
  const AlertaCard({super.key, required this.alerta, required this.onTap});

  final AlertaDesaparecido alerta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CentinelaColors.surface,
      borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(CentinelaSpacing.md),
          child: Row(
            children: [
              _FotoThumbnail(fotoUrl: alerta.fotoUrl, nombre: alerta.nombrePersona),
              const SizedBox(width: CentinelaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerta.nombrePersona,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alerta.distanciaTexto,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CentinelaColors.community,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alerta.tiempoTexto,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CentinelaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: CentinelaColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FotoThumbnail extends StatelessWidget {
  const _FotoThumbnail({required this.fotoUrl, required this.nombre});

  final String fotoUrl;
  final String nombre;

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    return ClipRRect(
      borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
      child: Image.network(
        fotoUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _FotoPlaceholder(inicial: inicial),
      ),
    );
  }
}

class _FotoPlaceholder extends StatelessWidget {
  const _FotoPlaceholder({required this.inicial});

  final String inicial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: CentinelaColors.alertCritical.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
      ),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: CentinelaColors.alertCritical,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
