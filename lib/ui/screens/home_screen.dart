import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/alerta_desaparecido.dart';
import '../../config/app_env.dart';
import '../../services/admin_service.dart';
import '../../services/alerta_filtros_service.dart';
import '../../services/alerta_service.dart';
import '../../services/avistamiento_service.dart';
import '../../services/home_tips_service.dart';
import '../../services/location_service.dart';
import '../../services/share_service.dart';
import '../../services/user_role_service.dart';
import '../../services/witness_guide_service.dart';
import '../../utils/alerta_filtros.dart';
import '../../utils/user_facing_error.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/alerta_card.dart';
import '../widgets/centinela_chip.dart';
import '../widgets/centinela_empty_state.dart';
import '../widgets/centinela_logo.dart';
import '../widgets/centinela_map_marker.dart';
import '../widgets/emitir_alerta_fab.dart';
import 'acerca_screen.dart';
import 'admin_screen.dart';
import 'detalle_alerta_screen.dart';
import 'emision_screen.dart';
import 'historial_screen.dart';
import '../../services/legal_service.dart';
import 'mi_alerta_screen.dart';

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
  List<AlertaDesaparecido> _alertasFiltradas = [];
  String? _error;
  bool _loading = true;
  bool _tieneAlertaActiva = false;
  ModoUsuario _modo = ModoUsuario.emisor;
  FiltroDistanciaKm _filtroDistancia = FiltroDistanciaKm.sinLimite;
  FiltroAntiguedad _filtroAntiguedad = FiltroAntiguedad.todas;
  StreamSubscription<List<AlertaDesaparecido>>? _alertasSub;
  StreamSubscription<int>? _avistamientosSub;
  Timer? _ubicacionTimer;
  int _lastAvistamientoCount = 0;
  bool _avistamientosReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarFiltros();
    _cargarModo();
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

  Future<void> _cargarModo() async {
    final modo = await UserRoleService.getModo();
    if (mounted) setState(() => _modo = modo);
  }

  Future<void> _abrirAcerca() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AcercaScreen()),
    );
    await _cargarModo();
  }

  Future<void> _compartirSitio() async {
    final ok = await launchUrl(
      Uri.parse(AppEnv.webUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el sitio web')),
      );
    }
  }

  Future<void> _cargarFiltros() async {
    _filtroDistancia = await AlertaFiltrosService.getDistancia();
    _filtroAntiguedad = await AlertaFiltrosService.getAntiguedad();
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    _alertasFiltradas = aplicarFiltrosAlertas(
      _alertas,
      distancia: _filtroDistancia,
      antiguedad: _filtroAntiguedad,
    );
  }

  Future<void> _cambiarFiltros({
    FiltroDistanciaKm? distancia,
    FiltroAntiguedad? antiguedad,
  }) async {
    if (distancia != null) _filtroDistancia = distancia;
    if (antiguedad != null) _filtroAntiguedad = antiguedad;
    await AlertaFiltrosService.save(
      distancia: _filtroDistancia,
      antiguedad: _filtroAntiguedad,
    );
    if (mounted) setState(_aplicarFiltros);
  }

  Future<void> _checkAlertaActiva() async {
    final id = await AlertaService.miAlertaActivaId();
    if (mounted) setState(() => _tieneAlertaActiva = id != null);
  }

  Future<void> _abrirHistorial() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HistorialScreen()),
    );
  }

  Future<void> _abrirAdminSiPermitido() async {
    if (!await AdminService.esAdmin()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso admin no autorizado')),
      );
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminScreen()),
    );
  }

  Future<void> _abrirMiAlerta() async {
    final resuelto = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const MiAlertaScreen()),
    );
    if (resuelto == true) await _initLocation();
    await _checkAlertaActiva();
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
        _aplicarFiltros();
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(centro, 15);
      });

      _subscribeRealtime(centro);
      await _checkAlertaActiva();
      await _watchMisAvistamientos();
      if (mounted) await WitnessGuideService.showIfNeeded(context);
      if (mounted) await HomeTipsService.showIfNeeded(context);
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
        if (mounted) {
          setState(() {
            _alertas = alertas;
            _aplicarFiltros();
          });
        }
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
    await _checkAlertaActiva();
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
                      initialZoom: 15,
                      minZoom: 5,
                      maxZoom: 19,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName:
                            'com.axeljhostin.centinela.centinela',
                      ),
                      MarkerLayer(
                        markers: _alertasFiltradas.map(_markerForAlerta).toList(),
                      ),
                      IgnorePointer(
                        child: MarkerLayer(
                          markers: [
                            Marker(
                              point: centro,
                              width: 24,
                              height: 24,
                              child: const CentinelaUserMarker(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: AppBar(
                        title: GestureDetector(
                          onLongPress: _abrirAdminSiPermitido,
                          child: CentinelaLogo.compact(),
                        ),
                        backgroundColor:
                            CentinelaColors.surface.withValues(alpha: 0.95),
                        surfaceTintColor: Colors.transparent,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            tooltip: 'Acerca y actualizaciones',
                            onPressed: _abrirAcerca,
                          ),
                          IconButton(
                            icon: const Icon(Icons.history),
                            tooltip: 'Historial',
                            onPressed: _abrirHistorial,
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Actualizar',
                            onPressed: _initLocation,
                          ),
                          IconButton(
                            icon: const Icon(Icons.gavel_outlined),
                            tooltip: 'Política de privacidad',
                            onPressed: () async {
                              final ok =
                                  await LegalService.openPrivacyPolicyInBrowser();
                              if (!context.mounted) return;
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No se pudo abrir la política de privacidad',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_tieneAlertaActiva)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 88,
                    child: Material(
                      color: CentinelaColors.alertCritical,
                      borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
                      elevation: 4,
                      child: InkWell(
                        onTap: _abrirMiAlerta,
                        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.campaign_outlined, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tienes una alerta activa — ver estado',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.white70),
                            ],
                          ),
                        ),
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
                      if (_modo == ModoUsuario.emisor)
                        EmitirAlertaFab(onPressed: _abrirEmision)
                      else
                        Material(
                          color: CentinelaColors.surface,
                          borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
                          elevation: 2,
                          child: InkWell(
                            onTap: _abrirAcerca,
                            borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility_outlined,
                                    color: CentinelaColors.community,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Modo testigo',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: CentinelaColors.community,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(CentinelaSpacing.lg),
          child: CircularProgressIndicator(color: CentinelaColors.community),
        ),
      );
    }
    if (_error != null) {
      return CentinelaEmptyState(
        icon: Icons.error_outline,
        iconColor: CentinelaColors.alertCritical,
        title: 'No pudimos cargar las alertas',
        subtitle: userFacingError(_error!),
        actionLabel: 'Reintentar',
        onAction: _initLocation,
      );
    }

    return Column(
      children: [
        if (AlertaService.usandoCache)
          Container(
            width: double.infinity,
            color: CentinelaColors.community.withValues(alpha: 0.12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _offlineBannerText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CentinelaColors.community,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                'Alertas activas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              CentinelaChip(
                label: '${_alertasFiltradas.length} cerca',
                icon: Icons.radar,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<FiltroDistanciaKm>(
                  initialValue: _filtroDistancia,
                  decoration: const InputDecoration(
                    labelText: 'Distancia',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: FiltroDistanciaKm.values
                      .map((f) => DropdownMenuItem(value: f, child: Text(f.etiqueta)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) _cambiarFiltros(distancia: v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<FiltroAntiguedad>(
                  initialValue: _filtroAntiguedad,
                  decoration: const InputDecoration(
                    labelText: 'Antigüedad',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: FiltroAntiguedad.values
                      .map((f) => DropdownMenuItem(value: f, child: Text(f.etiqueta)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) _cambiarFiltros(antiguedad: v);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: CentinelaColors.community,
            onRefresh: _initLocation,
            child: _alertasFiltradas.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 120,
                        child: CentinelaEmptyState(
                          title: _alertas.isEmpty
                              ? 'Tu zona está tranquila por ahora'
                              : 'Ninguna alerta con estos filtros',
                          subtitle: _alertas.isEmpty
                              ? (_modo == ModoUsuario.testigo
                                  ? 'Mantente atento a las notificaciones. '
                                      'Invita vecinos a instalar Centinela.'
                                  : 'No hay alertas activas cerca de ti. '
                                      'Si necesitas ayuda, usa el botón rojo del mapa.')
                              : 'Prueba ampliar distancia o antigüedad.',
                          icon: Icons.shield_outlined,
                          actionLabel: _alertas.isEmpty ? 'Invitar vecinos' : null,
                          onAction: _alertas.isEmpty ? _compartirSitio : null,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    itemCount: _alertasFiltradas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alerta = _alertasFiltradas[index];
                      return AlertaCard(
                        alerta: alerta,
                        onTap: () => _openDetalle(alerta),
                        onShare: () => _compartirWhatsApp(alerta),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  String _offlineBannerText() {
    final ts = AlertaService.cacheGuardadoEn;
    if (ts == null) return 'Sin conexión — mostrando datos guardados';
    final min = DateTime.now().difference(ts).inMinutes;
    if (min < 1) return 'Sin conexión — datos de hace un momento';
    return 'Sin conexión — datos de hace $min min';
  }

  Marker _markerForAlerta(AlertaDesaparecido alerta) {
    return Marker(
      point: LatLng(alerta.latitud, alerta.longitud),
      width: 48,
      height: 56,
      child: GestureDetector(
        onTap: () => _openDetalle(alerta),
        child: CentinelaMapMarker(photoUrl: alerta.fotoUrl),
      ),
    );
  }

  Future<void> _compartirWhatsApp(AlertaDesaparecido alerta) async {
    final ok = await ShareService.compartirWhatsApp(alerta);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  void _openDetalle(AlertaDesaparecido alerta) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetalleAlertaScreen(alerta: alerta),
      ),
    );
  }
}
