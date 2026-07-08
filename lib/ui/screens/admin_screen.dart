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
      final data = await AdminService.listarAlertas(estado: _filtroEstado);
      if (mounted) {
        setState(() {
          _alertas = data;
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
          : ListView.separated(
              padding: const EdgeInsets.all(CentinelaSpacing.md),
              itemCount: _alertas.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final a = _alertas[index];
                final id = a['id'] as String;
                final estado = a['estado'] as String? ?? '';
                return ListTile(
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
                );
              },
            ),
    );
  }
}
