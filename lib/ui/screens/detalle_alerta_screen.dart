import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../models/alerta_desaparecido.dart';
import '../../services/alerta_service.dart';
import '../../services/avistamiento_service.dart';
import '../../services/cache_service.dart';
import '../../services/geocoding_service.dart';
import '../../services/moderacion_service.dart';
import '../../services/push_service.dart';
import '../../services/share_service.dart';
import '../../utils/user_facing_error.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/avistamiento_mapa_dialog.dart';
import '../widgets/centinela_action_button.dart';
import '../widgets/centinela_chip.dart';
import '../widgets/centinela_section_card.dart';
import 'confirmar_avistamiento_screen.dart';

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
  bool _compartiendo = false;
  bool _reportandoFalsa = false;

  @override
  void initState() {
    super.initState();
    CacheService.guardarDetalle(widget.alerta);
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
      await PushService.notificarComunidadResuelto(
        alertaId: widget.alerta.id,
        lat: widget.alerta.latitud,
        lng: widget.alerta.longitud,
        radioKm: widget.alerta.radioKm,
        nombrePersona: widget.alerta.nombrePersona,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _resolviendo = false);
    }
  }

  Future<void> _compartirWhatsApp() async {
    setState(() => _compartiendo = true);
    try {
      final ok = await ShareService.compartirWhatsApp(widget.alerta);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  Future<void> _reportarLoVi() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ConfirmarAvistamientoScreen(
          alertaId: widget.alerta.id,
          alertaLat: widget.alerta.latitud,
          alertaLng: widget.alerta.longitud,
        ),
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gracias. Tu avistamiento fue registrado.'),
          backgroundColor: CentinelaColors.community,
        ),
      );
    }
  }

  Future<void> _reportarAlertaFalsa() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Reportar alerta falsa?'),
        content: const Text(
          'Tu reporte ayuda a proteger a la comunidad. '
          'Con 3 reportes independientes la alerta se ocultará.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: CentinelaColors.alertCritical),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _reportandoFalsa = true);
    try {
      await ModeracionService.reportarAlertaFalsa(widget.alerta.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte enviado. Gracias por ayudar a la comunidad.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _reportandoFalsa = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerta = widget.alerta;
    final esEmisor = _esEmisor == true;

    return Scaffold(
      body: Column(
        children: [
          _PhotoHero(
            alerta: alerta,
            showReport: !esEmisor && _esEmisor != null,
            reportando: _reportandoFalsa,
            onReport: _reportarAlertaFalsa,
          ),
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    CentinelaChip(
                      label: '${alerta.edadAprox} años aprox.',
                      icon: Icons.person_outline,
                      color: CentinelaColors.textSecondary,
                      filled: false,
                    ),
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
                if (alerta.ultimaVistaTexto.isNotEmpty) ...[
                  const SizedBox(height: CentinelaSpacing.md),
                  CentinelaSectionCard(
                    title: 'Último lugar visto',
                    body: alerta.ultimaVistaTexto,
                    icon: Icons.place_outlined,
                  ),
                ],
                const SizedBox(height: CentinelaSpacing.lg),
                if (esEmisor)
                  _AvistamientosEmisorCard(
                    alertaId: alerta.id,
                    origenAlerta: LatLng(alerta.latitud, alerta.longitud),
                  ),
                if (esEmisor) const SizedBox(height: CentinelaSpacing.lg),
                if (alerta.vestimenta.isNotEmpty)
                  CentinelaSectionCard(
                    title: 'Vestimenta',
                    body: alerta.vestimenta,
                    icon: Icons.checkroom_outlined,
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
                          onPressed: _compartiendo ? null : _compartirWhatsApp,
                        ),
                        const SizedBox(width: 12),
                        CentinelaActionButton(
                          label: '¡Lo Vi!',
                          color: CentinelaColors.community,
                          icon: Icons.my_location,
                          onPressed: _reportarLoVi,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvistamientosEmisorCard extends StatefulWidget {
  const _AvistamientosEmisorCard({
    required this.alertaId,
    required this.origenAlerta,
  });

  final String alertaId;
  final LatLng origenAlerta;

  @override
  State<_AvistamientosEmisorCard> createState() => _AvistamientosEmisorCardState();
}

class _AvistamientosEmisorCardState extends State<_AvistamientosEmisorCard> {
  List<AvistamientoResumen> _resumen = [];
  StreamSubscription<int>? _sub;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _sub = AvistamientoService.watchCount(widget.alertaId).listen((count) {
      if (mounted) setState(() => _count = count);
      _loadResumen();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadResumen() async {
    try {
      final items = await AvistamientoService.resumen(widget.alertaId);
      final enriched = <AvistamientoResumen>[];
      for (final item in items) {
        if (item.ubicacionTexto != null && item.ubicacionTexto!.isNotEmpty) {
          enriched.add(item);
          continue;
        }
        final label = await GeocodingService.reverseLabel(
          LatLng(item.lat, item.lng),
        );
        enriched.add(item.copyWith(lugarResuelto: label));
      }
      if (mounted) setState(() => _resumen = enriched);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CentinelaSpacing.md),
      decoration: BoxDecoration(
        color: CentinelaColors.community.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        border: Border.all(color: CentinelaColors.community.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, color: CentinelaColors.community),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _count == 0
                      ? 'Aún no hay avistamientos. Comparte por WhatsApp.'
                      : '$_count persona${_count == 1 ? '' : 's'} reportaron «Lo vi»',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_resumen.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._resumen.map((r) => _AvistamientoResumenTile(
                  resumen: r,
                  origenAlerta: widget.origenAlerta,
                )),
          ],
        ],
      ),
    );
  }
}

class _AvistamientoResumenTile extends StatelessWidget {
  const _AvistamientoResumenTile({
    required this.resumen,
    required this.origenAlerta,
  });

  final AvistamientoResumen resumen;
  final LatLng origenAlerta;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(CentinelaSpacing.sm),
      decoration: BoxDecoration(
        color: CentinelaColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        border: Border.all(color: CentinelaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place_outlined, size: 18, color: CentinelaColors.community),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  resumen.lugarDisplay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${resumen.distanciaKm.toStringAsFixed(1)} km de tu punto reportado · ${resumen.tiempoTexto}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: CentinelaColors.textSecondary,
            ),
          ),
          if (resumen.notaTestigo != null && resumen.notaTestigo!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '«${resumen.notaTestigo}»',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => AvistamientoMapaDialog.show(
                context,
                origenAlerta: origenAlerta,
                puntoAvistamiento: LatLng(resumen.lat, resumen.lng),
                titulo: 'Mapa del avistamiento',
                etiquetaAvistamiento: resumen.lugarDisplay,
              ),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Ver en mapa'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoHero extends StatelessWidget {
  const _PhotoHero({
    required this.alerta,
    this.showReport = false,
    this.reportando = false,
    this.onReport,
  });

  final AlertaDesaparecido alerta;
  final bool showReport;
  final bool reportando;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                alerta.fotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: CentinelaColors.alertCritical.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, size: 80, color: CentinelaColors.alertCritical),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: CentinelaColors.border,
                    child: const Center(
                      child: CircularProgressIndicator(color: CentinelaColors.community),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                  style: IconButton.styleFrom(backgroundColor: Colors.black38),
                ),
                const Spacer(),
                if (showReport)
                  IconButton(
                    onPressed: reportando ? null : onReport,
                    icon: reportando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.flag_outlined, color: Colors.white),
                    tooltip: 'Reportar alerta falsa',
                    style: IconButton.styleFrom(backgroundColor: Colors.black38),
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
