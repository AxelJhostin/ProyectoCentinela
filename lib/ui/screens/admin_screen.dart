import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../theme/centinela_spacing.dart';

/// Panel admin MVP (Sprint 10) — solo visible si es_admin().
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _alertas = [];
  Map<String, dynamic> _metricas = {};
  bool _loading = true;
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AdminService.listarAlertas(estado: _filtroEstado),
        AdminService.obtenerMetricasSitio(),
      ]);
      if (mounted) {
        setState(() {
          _alertas = results[0] as List<Map<String, dynamic>>;
          _metricas = results[1] as Map<String, dynamic>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error admin: $e')),
        );
      }
    }
  }

  Future<void> _forzarEstado(String alertaId, String estado) async {
    try {
      await AdminService.forzarEstado(alertaId, estado);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  int _metrica(String key) => (_metricas[key] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Centinela'),
        actions: [
          PopupMenuButton<String?>(
            onSelected: (v) {
              _filtroEstado = v;
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('Todas')),
              PopupMenuItem(value: 'ACTIVA', child: Text('Activas')),
              PopupMenuItem(value: 'RESUELTA', child: Text('Resueltas')),
              PopupMenuItem(value: 'FALSA_ALARMA', child: Text('Falsa alarma')),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(CentinelaSpacing.md),
              children: [
                Text(
                  'Sitio web (proyecto-centinela.vercel.app)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CentinelaSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _MetricChip(
                        label: 'Visitas',
                        value: _metrica('visitas'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricChip(
                        label: 'Descargas',
                        value: _metrica('descargas_apk'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricChip(
                        label: 'Compartidos',
                        value: _metrica('compartidos'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: CentinelaSpacing.lg),
                Text(
                  'Alertas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CentinelaSpacing.sm),
                ..._alertas.map((a) {
                  final id = a['id'] as String;
                  final estado = a['estado'] as String? ?? '';
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(a['nombre_persona'] as String? ?? 'Sin nombre'),
                        subtitle: Text('$estado · score ${a['score_confiabilidad']}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (nuevo) => _forzarEstado(id, nuevo),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'RESUELTA', child: Text('Marcar resuelta')),
                            PopupMenuItem(value: 'FALSA_ALARMA', child: Text('Falsa alarma')),
                            PopupMenuItem(value: 'ACTIVA', child: Text('Reactivar')),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                }),
              ],
            ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
