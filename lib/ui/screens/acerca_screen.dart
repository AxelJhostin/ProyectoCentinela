import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_env.dart';
import '../../services/user_role_service.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/centinela_logo.dart';

/// Información de la app, actualizaciones APK y preferencias de uso.
class AcercaScreen extends StatefulWidget {
  const AcercaScreen({super.key});

  @override
  State<AcercaScreen> createState() => _AcercaScreenState();
}

class _AcercaScreenState extends State<AcercaScreen> {
  String _version = '…';
  ModoUsuario _modo = ModoUsuario.emisor;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    final modo = await UserRoleService.getModo();
    if (!mounted) return;
    setState(() {
      _version = '${info.version} (${info.buildNumber})';
      _modo = modo;
      _loading = false;
    });
  }

  Future<void> _abrir(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir ${uri.host}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de Centinela')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(CentinelaSpacing.lg),
              children: [
                const Center(child: CentinelaLogo()),
                const SizedBox(height: CentinelaSpacing.md),
                Text(
                  'Versión instalada: $_version',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CentinelaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: CentinelaSpacing.lg),
                _SectionCard(
                  title: 'Actualizar la app',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Las nuevas versiones del piloto se publican en la web. '
                        'Descarga e instala el APK más reciente (reemplaza la anterior).',
                      ),
                      const SizedBox(height: CentinelaSpacing.md),
                      FilledButton.icon(
                        onPressed: () => _abrir(Uri.parse(AppEnv.apkDownloadUrl)),
                        icon: const Icon(Icons.android),
                        label: const Text('Descargar última versión'),
                      ),
                      TextButton(
                        onPressed: () => _abrir(Uri.parse(AppEnv.webUrl)),
                        child: const Text('Abrir sitio web'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: CentinelaSpacing.md),
                _SectionCard(
                  title: 'Tu modo en Centinela',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Elige si solo quieres ayudar recibiendo alertas o también '
                        'puedes emitir una en emergencia.',
                      ),
                      const SizedBox(height: CentinelaSpacing.sm),
                      ...ModoUsuario.values.map((m) {
                        return RadioListTile<ModoUsuario>(
                          value: m,
                          groupValue: _modo,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            m.etiqueta,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            m == ModoUsuario.testigo
                                ? 'Ocultamos el botón rojo de emitir alerta.'
                                : 'Acceso completo para reportar desapariciones.',
                          ),
                          onChanged: (v) async {
                            if (v == null) return;
                            await UserRoleService.setModo(v);
                            if (!mounted) return;
                            setState(() => _modo = v);
                          },
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: CentinelaSpacing.md),
                _SectionCard(
                  title: 'Invitar a tu comunidad',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Comparte el sitio para que más vecinos de Manabí '
                        'instalen Centinela y reciban alertas.',
                      ),
                      const SizedBox(height: CentinelaSpacing.md),
                      OutlinedButton.icon(
                        onPressed: () => _abrir(Uri.parse(AppEnv.webUrl)),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Compartir enlace del sitio'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CentinelaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: CentinelaSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
