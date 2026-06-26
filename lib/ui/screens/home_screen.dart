import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';
import '../theme/centinela_theme.dart';

/// Pantalla temporal Sprint 0 — placeholder del Home (mapa + FAB en Sprint 1).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _statusMessage;
  bool _loading = false;

  Future<void> _testConnection() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    try {
      final message = await SupabaseService.runConnectionTest();
      setState(() => _statusMessage = message);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centinela')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_outlined, size: 64, color: CentinelaColors.alertCritical),
            const SizedBox(height: 16),
            Text(
              'Sprint 0 — Motor encendido',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Próximo: mapa, bottom sheet y formulario de emisión (Sprint 1).',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loading ? null : _testConnection,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_done_outlined),
              label: Text(_loading ? 'Probando…' : 'Probar conexión Supabase'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _statusMessage!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.campaign),
        label: const Text('EMITIR ALERTA'),
      ),
    );
  }
}
