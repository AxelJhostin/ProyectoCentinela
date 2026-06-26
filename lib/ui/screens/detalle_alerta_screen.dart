import 'package:flutter/material.dart';

import '../../models/alerta_desaparecido.dart';
import '../../services/alerta_service.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/centinela_action_button.dart';

/// Pantalla 3 — Detalle de alerta (Sprint 2: foto real + resolver si eres emisor).
class DetalleAlertaScreen extends StatefulWidget {
  const DetalleAlertaScreen({super.key, required this.alerta});

  final AlertaDesaparecido alerta;

  @override
  State<DetalleAlertaScreen> createState() => _DetalleAlertaScreenState();
}

class _DetalleAlertaScreenState extends State<DetalleAlertaScreen> {
  bool? _esEmisor;
  bool _resolviendo = false;

  @override
  void initState() {
    super.initState();
    _checkEmisor();
  }

  Future<void> _checkEmisor() async {
    final miId = await AlertaService.currentUsuarioId;
    if (mounted) {
      setState(() => _esEmisor = miId != null && miId == widget.alerta.emisorId);
    }
  }

  Future<void> _resolver() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Marcar como resuelto?'),
        content: const Text('La alerta se ocultará de la comunidad.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, resolver')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _resolviendo = true);
    try {
      await AlertaService.resolverAlerta(widget.alerta.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _resolviendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerta = widget.alerta;
    final esEmisor = _esEmisor == true;

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
                Text('Edad aproximada: ${alerta.edadAprox} años'),
                const SizedBox(height: 4),
                Text(
                  'A ${alerta.distanciaKm.toStringAsFixed(1)} km de tu ubicación',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CentinelaColors.community,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: CentinelaSpacing.lg),
                if (alerta.vestimenta.isNotEmpty)
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
                        Text(alerta.vestimenta),
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
              child: esEmisor
                  ? FilledButton(
                      onPressed: _resolviendo ? null : _resolver,
                      child: _resolviendo
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('MARCAR COMO RESUELTO'),
                    )
                  : Row(
                      children: [
                        CentinelaActionButton(
                          label: 'Compartir WhatsApp',
                          color: CentinelaColors.whatsApp,
                          icon: Icons.share,
                          onPressed: () => _mockAction('WhatsApp (Sprint 3)'),
                        ),
                        const SizedBox(width: 12),
                        CentinelaActionButton(
                          label: '¡Lo Vi!',
                          color: CentinelaColors.community,
                          icon: Icons.my_location,
                          onPressed: () => _mockAction('Avistamiento (Sprint 3)'),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _mockAction(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Próximamente: $feature')),
    );
  }
}

class _PhotoHero extends StatelessWidget {
  const _PhotoHero({required this.alerta});

  final AlertaDesaparecido alerta;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: Image.network(
            alerta.fotoUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: CentinelaColors.alertCritical.withValues(alpha: 0.15),
              child: const Icon(Icons.person, size: 80, color: CentinelaColors.alertCritical),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black38),
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
