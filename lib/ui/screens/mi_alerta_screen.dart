import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../models/alerta_desaparecido.dart';
import '../../services/alerta_service.dart';
import '../../services/avistamiento_service.dart';
import '../../services/compartir_service.dart';
import '../../services/geocoding_service.dart';
import '../../services/maps_service.dart';
import '../../services/push_service.dart';
import '../../services/share_service.dart';
import '../../utils/user_facing_error.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/avistamiento_mapa_dialog.dart';
import '../widgets/centinela_action_button.dart';
import '../widgets/centinela_chip.dart';
import '../widgets/centinela_section_card.dart';

/// Hub del emisor: estado, avistamientos y acciones rápidas (Sprint 8).
class MiAlertaScreen extends StatefulWidget {
  const MiAlertaScreen({super.key});

  @override
  State<MiAlertaScreen> createState() => _MiAlertaScreenState();
}

class _MiAlertaScreenState extends State<MiAlertaScreen> {
  AlertaDesaparecido? _alerta;
  List<AvistamientoResumen> _resumen = [];
  int _count = 0;
  int _compartidos = 0;
  bool _loading = true;
  bool _resolviendo = false;
  bool _compartiendo = false;
  String? _error;
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final alertaId = await AlertaService.miAlertaActivaId();
      if (alertaId == null) {
        if (mounted) {
          setState(() {
            _loading = false;
            _alerta = null;
          });
        }
        return;
      }

      final alerta = await AlertaService.fetchById(alertaId);
      if (!mounted) return;

      if (alerta == null) {
        setState(() {
          _loading = false;
          _error = 'No encontramos tu alerta activa.';
        });
        return;
      }

      setState(() {
        _alerta = alerta;
        _loading = false;
      });

      _sub?.cancel();
      _sub = AvistamientoService.watchCount(alertaId).listen((n) {
        if (mounted) setState(() => _count = n);
        _loadResumen(alertaId);
      });
      _count = await AvistamientoService.contar(alertaId);
      _compartidos = await CompartirService.contar(alertaId);
      await _loadResumen(alertaId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _loadResumen(String alertaId) async {
    try {
      final items = await AvistamientoService.resumen(alertaId);
      final enriched = <AvistamientoResumen>[];
      for (final item in items) {
        if (item.ubicacionTexto != null && item.ubicacionTexto!.isNotEmpty) {
          enriched.add(item);
          continue;
        }
        final label = await GeocodingService.reverseLabel(LatLng(item.lat, item.lng));
        enriched.add(item.copyWith(lugarResuelto: label));
      }
      if (mounted) setState(() => _resumen = enriched);
    } catch (_) {}
  }

  Future<void> _resolver() async {
    final alerta = _alerta;
    if (alerta == null) return;

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
      await AlertaService.resolverAlerta(alerta.id);
      await PushService.notificarComunidadResuelto(
        alertaId: alerta.id,
        lat: alerta.latitud,
        lng: alerta.longitud,
        radioKm: alerta.radioKm,
        nombrePersona: alerta.nombrePersona,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _resolviendo = false);
    }
  }

  Future<void> _compartir() async {
    final alerta = _alerta;
    if (alerta == null) return;
    setState(() => _compartiendo = true);
    try {
      final ok = await ShareService.compartirWhatsApp(alerta);
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

  Future<void> _abrirEnMapa() async {
    final alerta = _alerta;
    if (alerta == null) return;
    final ok = await MapsService.abrirAvistamiento(
      lat: alerta.latitud,
      lng: alerta.longitud,
      etiqueta: alerta.ultimaVistaTexto.isNotEmpty
          ? alerta.ultimaVistaTexto
          : alerta.nombrePersona,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi alerta activa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _alerta != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(CentinelaSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CentinelaActionButton(
                            label: 'WhatsApp',
                            color: CentinelaColors.whatsApp,
                            icon: Icons.share,
                            onPressed: _compartiendo ? null : _compartir,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CentinelaActionButton(
                            label: 'En mapa',
                            color: CentinelaColors.community,
                            icon: Icons.map_outlined,
                            onPressed: _abrirEnMapa,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _resolviendo ? null : _resolver,
                      child: _resolviendo
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('MARCAR COMO RESUELTO'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: CentinelaColors.community),
      );
    }
    if (_error != null) {
      return Center(child: Text(_error!, textAlign: TextAlign.center));
    }
    if (_alerta == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No tienes una alerta activa.\nUsa el botón rojo del mapa para emitir una.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final alerta = _alerta!;
    return ListView(
      padding: const EdgeInsets.all(CentinelaSpacing.lg),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
          child: Image.network(
            alerta.fotoUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: 200,
              color: CentinelaColors.border,
              child: const Icon(Icons.person, size: 64),
            ),
          ),
        ),
        const SizedBox(height: CentinelaSpacing.md),
        Text(
          alerta.nombrePersona,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CentinelaChip(label: alerta.tiempoTexto, icon: Icons.schedule),
            CentinelaChip(
              label: 'Radio ${alerta.radioKm} km',
              icon: Icons.radar,
              color: CentinelaColors.textSecondary,
              filled: false,
            ),
            CentinelaChip(
              label: _count == 0
                  ? 'Sin avistamientos'
                  : '$_count «Lo vi»',
              icon: Icons.visibility_outlined,
            ),
            CentinelaChip(
              label: _compartidos == 0
                  ? 'Sin compartidos'
                  : 'Compartida $_compartidos veces',
              icon: Icons.share,
              color: CentinelaColors.whatsApp,
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
        Text(
          'Avistamientos de la comunidad',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (_resumen.isEmpty)
          Text(
            'Comparte por WhatsApp para llegar a más personas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CentinelaColors.textSecondary,
            ),
          )
        else
          ..._resumen.map(
            (r) => _AvistamientoTile(
              resumen: r,
              origen: LatLng(alerta.latitud, alerta.longitud),
            ),
          ),
      ],
    );
  }
}

class _AvistamientoTile extends StatelessWidget {
  const _AvistamientoTile({required this.resumen, required this.origen});

  final AvistamientoResumen resumen;
  final LatLng origen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(CentinelaSpacing.sm),
      decoration: BoxDecoration(
        color: CentinelaColors.surface,
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        border: Border.all(color: CentinelaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resumen.lugarDisplay,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            resumen.lineaPrincipal,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: CentinelaColors.textSecondary,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => AvistamientoMapaDialog.show(
                context,
                origenAlerta: origen,
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
