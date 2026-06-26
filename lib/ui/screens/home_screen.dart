import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/mock_alertas.dart';
import '../../models/alerta_desaparecido.dart';
import '../theme/centinela_theme.dart';
import '../widgets/alerta_card.dart';
import '../widgets/emitir_alerta_fab.dart';
import 'emision_screen.dart';
import 'detalle_alerta_screen.dart';

/// Pantalla 1 — Mapa principal + bottom sheet + FAB (Sprint 1, mock data).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mapController = MapController();
  final _alertas = MockAlertas.alertas;

  @override
  Widget build(BuildContext context) {
    final centro = LatLng(MockAlertas.centroLat, MockAlertas.centroLng);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.axeljhostin.centinela',
              ),
              MarkerLayer(
                markers: [
                  ..._alertas.map(_markerForAlerta),
                  Marker(
                    point: centro,
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: CentinelaColors.community,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AppBar(
                title: const Text('Centinela'),
                backgroundColor: CentinelaColors.surface.withValues(alpha: 0.92),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.24,
            minChildSize: 0.16,
            maxChildSize: 0.55,
            builder: (context, scrollController) {
              return Container(
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
                child: Column(
                  children: [
                    const SizedBox(height: 12),
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
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: EmitirAlertaFab(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const EmisionScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
