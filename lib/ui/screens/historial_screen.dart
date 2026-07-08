import 'package:flutter/material.dart';

import '../../models/alerta_desaparecido.dart';
import '../../services/alerta_service.dart';
import '../../services/location_service.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/alerta_card.dart';
import '../widgets/centinela_empty_state.dart';
import 'detalle_alerta_screen.dart';

/// Historial de alertas resueltas/cerradas (Sprint 9).
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<AlertaDesaparecido> _cercanas = [];
  List<AlertaDesaparecido> _mias = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await LocationService.getCurrentPosition();
      final lat = pos?.latitude ?? -1.0;
      final lng = pos?.longitude ?? -80.5833;

      final results = await Future.wait([
        AlertaService.fetchHistorialCercano(lat: lat, lng: lng),
        AlertaService.fetchMiHistorial(),
      ]);

      if (!mounted) return;
      setState(() {
        _cercanas = results[0];
        _mias = results[1];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Cerca de mí'),
            Tab(text: 'Mis alertas'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: CentinelaColors.community),
            )
          : _error != null
              ? CentinelaEmptyState(
                  title: 'No pudimos cargar el historial',
                  subtitle: _error,
                  icon: Icons.error_outline,
                  iconColor: CentinelaColors.alertCritical,
                )
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _buildList(_cercanas, 'No hay casos cerrados cerca en los últimos 30 días.'),
                    _buildList(_mias, 'Aún no has emitido alertas que se hayan cerrado.'),
                  ],
                ),
    );
  }

  Widget _buildList(List<AlertaDesaparecido> alertas, String empty) {
    if (alertas.isEmpty) {
      return CentinelaEmptyState(
        title: empty,
        icon: Icons.history,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(CentinelaSpacing.md),
      itemCount: alertas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alerta = alertas[index];
        return AlertaCard(
          alerta: alerta,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetalleAlertaScreen(alerta: alerta),
            ),
          ),
        );
      },
    );
  }
}
