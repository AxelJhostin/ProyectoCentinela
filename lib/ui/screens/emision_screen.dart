import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Pantalla 2 — Formulario exprés de emisión (Sprint 1, mock submit).
class EmisionScreen extends StatefulWidget {
  const EmisionScreen({super.key});

  @override
  State<EmisionScreen> createState() => _EmisionScreenState();
}

class _EmisionScreenState extends State<EmisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _vestimentaController = TextEditingController();
  bool _fotoSeleccionada = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _vestimentaController.dispose();
    super.dispose();
  }

  void _simularFoto() {
    setState(() => _fotoSeleccionada = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock: foto seleccionada (Sprint 2 subirá a Supabase)')),
    );
  }

  void _enviar() {
    if (!_fotoSeleccionada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fotografía es obligatoria')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock: alerta enviada a la comunidad (Sprint 2 conectará backend)'),
        backgroundColor: CentinelaColors.alertCritical,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Reportar Desaparición'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(CentinelaSpacing.lg),
          children: [
            _UploadPhotoArea(
              seleccionada: _fotoSeleccionada,
              onTap: _simularFoto,
            ),
            const SizedBox(height: CentinelaSpacing.lg),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: CentinelaSpacing.md),
            TextFormField(
              controller: _edadController,
              decoration: const InputDecoration(labelText: 'Edad aproximada'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'La edad es obligatoria';
                final n = int.tryParse(v);
                if (n == null || n < 1 || n > 120) return 'Edad no válida';
                return null;
              },
            ),
            const SizedBox(height: CentinelaSpacing.md),
            TextFormField(
              controller: _vestimentaController,
              decoration: const InputDecoration(
                labelText: 'Vestimenta o rasgo particular',
                hintText: 'Ej: Camiseta roja, cicatriz en el brazo',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: CentinelaSpacing.lg),
            Text(
              'Última ubicación',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: CentinelaSpacing.sm),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: CentinelaColors.border.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
                border: Border.all(color: CentinelaColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 48, color: CentinelaColors.textSecondary.withValues(alpha: 0.5)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.location_on, color: CentinelaColors.alertCritical, size: 28),
                      Padding(
                        padding: const EdgeInsets.all(CentinelaSpacing.sm),
                        child: Text(
                          'GPS detectado · Arrastra el pin si es necesario',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CentinelaColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CentinelaSpacing.md),
          child: FilledButton(
            onPressed: _enviar,
            child: const Text('ENVIAR ALERTA A LA COMUNIDAD'),
          ),
        ),
      ),
    );
  }
}

class _UploadPhotoArea extends StatelessWidget {
  const _UploadPhotoArea({required this.seleccionada, required this.onTap});

  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: seleccionada
              ? CentinelaColors.community.withValues(alpha: 0.08)
              : CentinelaColors.surface,
          borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
          border: Border.all(
            color: seleccionada ? CentinelaColors.community : CentinelaColors.border,
            width: seleccionada ? 2 : 1.5,
          ),
        ),
        child: seleccionada
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 48, color: CentinelaColors.community),
                  const SizedBox(height: 8),
                  Text('Fotografía lista', style: Theme.of(context).textTheme.titleSmall),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 48, color: CentinelaColors.textSecondary),
                  const SizedBox(height: 8),
                  Text('Subir Fotografía', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Toca para seleccionar · Se comprime automáticamente',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CentinelaColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
