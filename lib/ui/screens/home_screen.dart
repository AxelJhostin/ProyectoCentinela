import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/alerta_desaparecido.dart';
import '../../services/alerta_service.dart';
import '../../services/avistamiento_service.dart';
import '../../services/location_service.dart';
import '../theme/centinela_theme.dart';
import '../widgets/alerta_card.dart';
import '../widgets/emitir_alerta_fab.dart';
import 'detalle_alerta_screen.dart';
import 'emision_screen.dart';
import 'legal_terms_screen.dart';

/// Pantalla 1 — Mapa + panel inferior con alertas activas (Sprint 2).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _mapController = MapController();
  LatLng? _userPosition;
  List<AlertaDesaparecido> _alertas = [];
  String? _error;
  bool _loading = true;
  StreamSubscription<List<AlertaDesaparecido>>? _alertasSub;
  StreamSubscription<int>? _avistamientosSub;
  Timer? _ubicacionTimer;
  int _lastAvistamientoCount = 0;
  bool _avistamientosReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocation();
    _ubicacionTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => LocationService.syncUbicacionToSupabase(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LocationService.syncUbicacionToSupabase();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alertasSub?.cancel();
    _avistamientosSub?.cancel();
    _ubicacionTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final pos = await LocationService.getCurrentPosition();
      final centro = pos != null
          ? LatLng(pos.latitude, pos.longitude)
          : const LatLng(-1.0, -80.5833);

      if (pos != null) {
        await LocationService.syncUbicacionToSupabase();
      }

      final alertas = await AlertaService.fetchActivas(
        userLat: centro.latitude,
        userLng: centro.longitude,
      );

      if (!mounted) return;
      setState(() {
        _userPosition = centro;
        _alertas = alertas;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(centro, 15);
      });

      _subscribeRealtime(centro);
      await _watchMisAvistamientos();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _subscribeRealtime(LatLng centro) {
    _alertasSub?.cancel();
    _alertasSub = AlertaService.watchActivas(
      userLat: centro.latitude,
      userLng: centro.longitude,
    ).listen(
      (alertas) {
        if (mounted) setState(() => _alertas = alertas);
      },
      onError: (Object e) {
        if (mounted) setState(() => _error = e.toString());
      },
    );
  }

  Future<void> _watchMisAvistamientos() async {
    _avistamientosSub?.cancel();
    _avistamientosReady = false;

    final alertaId = await AlertaService.miAlertaActivaId();
    if (alertaId == null) return;

    _lastAvistamientoCount = await AvistamientoService.contar(alertaId);
    _avistamientosReady = true;

    _avistamientosSub = AvistamientoService.watchCount(alertaId).listen((n) {
      if (!mounted) return;
      if (_avistamientosReady && n > _lastAvistamientoCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              n == 1
                  ? '¡Alguien reportó haber visto tu alerta!'
                  : '$n personas reportaron «Lo vi» en tu alerta',
            ),
            backgroundColor: CentinelaColors.community,
          ),
        );
      }
      _lastAvistamientoCount = n;
    });
  }

  Future<void> _abrirEmision() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EmisionScreen()),
    );
    await _initLocation();
  }

  @override
  Widget build(BuildContext context) {
    final centro = _userPosition ?? const LatLng(-1.0, -80.5833);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: centro,
                      initialZoom: 14,
                      backgroundColor: const Color(0xFFE8ECEF),
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.axeljhostin.centinela.centinela',
                      ),
                      MarkerLayer(
                        markers: [
                          ..._alertas.map(_markerForAlerta),
                          Marker(
                            point: centro,
                            width: 48,
                            height: 48,
                            child: const Icon(
                              Icons.my_location,
                              color: CentinelaColors.community,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AppBar(
                      title: const Text('Centinela'),
                      backgroundColor: CentinelaColors.surface.withValues(alpha: 0.95),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Actualizar',
                          onPressed: _initLocation,
                        ),
                        IconButton(
                          icon: const Icon(Icons.gavel_outlined),
                          tooltip: 'Términos y privacidad',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const LegalTermsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_userPosition != null)
                        FloatingActionButton.small(
                          heroTag: 'centro_mapa',
                          onPressed: () => _mapController.move(_userPosition!, 15),
                          backgroundColor: CentinelaColors.surface,
                          foregroundColor: CentinelaColors.community,
                          elevation: 3,
                          child: const Icon(Icons.my_location),
                        ),
                      const SizedBox(height: 12),
                      EmitirAlertaFab(onPressed: _abrirEmision),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomPanel(context),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.32,
        minHeight: 132,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: CentinelaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: _buildSheetContent(context),
    );
  }

  Widget _buildSheetContent(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $_error', textAlign: TextAlign.center),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: CentinelaColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                'Alertas activas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${_alertas.length} cerca',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CentinelaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _alertas.isEmpty
              ? Center(
                  child: Text(
                    'No hay alertas activas en tu zona.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CentinelaColors.textSecondary,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  itemCount: _alertas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final alerta = _alertas[index];
                    return AlertaCard(
                      alerta: alerta,
                      onTap: () => _openDetalle(alerta),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Marker _markerForAlerta(AlertaDesaparecido alerta) {
    return Marker(
      point: LatLng(alerta.latitud, alerta.longitud),
      width: 36,
      height: 36,
      child: const Icon(
        Icons.location_on,
        color: CentinelaColors.alertCritical,
        size: 36,
      ),
    );
  }

  void _openDetalle(AlertaDesaparecido alerta) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetalleAlertaScreen(alerta: alerta),
      ),
    );
  }
}
