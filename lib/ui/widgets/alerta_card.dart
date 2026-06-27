import 'package:flutter/material.dart';

import '../../models/alerta_desaparecido.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import 'centinela_chip.dart';

/// Tarjeta de alerta en el bottom sheet del Home.
class AlertaCard extends StatelessWidget {
  const AlertaCard({
    super.key,
    required this.alerta,
    required this.onTap,
    this.onShare,
  });

  final AlertaDesaparecido alerta;
  final VoidCallback onTap;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CentinelaColors.surface,
      borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
      elevation: 0,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
            border: Border.all(color: CentinelaColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: CentinelaColors.alertCritical,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(CentinelaSpacing.radiusLg),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(CentinelaSpacing.md),
                    child: Row(
                      children: [
                        _FotoThumbnail(
                          fotoUrl: alerta.fotoUrl,
                          nombre: alerta.nombrePersona,
                        ),
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
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  CentinelaChip(
                                    label: alerta.distanciaTexto,
                                    icon: Icons.near_me_outlined,
                                  ),
                                  CentinelaChip(
                                    label: alerta.tiempoTexto,
                                    icon: Icons.schedule,
                                    color: CentinelaColors.textSecondary,
                                    filled: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (onShare != null)
                          IconButton(
                            icon: const Icon(Icons.share, color: CentinelaColors.whatsApp),
                            tooltip: 'Compartir WhatsApp',
                            onPressed: onShare,
                          ),
                        const Icon(Icons.chevron_right, color: CentinelaColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        border: Border.all(color: CentinelaColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd - 1),
        child: Image.network(
          fotoUrl,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _FotoPlaceholder(inicial: inicial),
        ),
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
