import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../models/push_dispatch_result.dart';
import '../../services/alerta_service.dart';
import '../../services/foto_service.dart';
import '../../services/location_service.dart';
import '../../services/push_service.dart';
import '../../services/share_service.dart';
import '../../utils/user_facing_error.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/centinela_section_card.dart';
import '../widgets/ubicacion_pin_picker.dart';

/// Pantalla 2 — Formulario exprés con foto real y guardado en Supabase (Sprint 2).
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
  final _ultimaVistaController = TextEditingController();

  Uint8List? _fotoBytes;
  LatLng? _ubicacionPin;
  int _radioKm = 10;
  bool _enviando = false;

  static const _radiosDisponibles = [10, 30, 50];

  @override
  void initState() {
    super.initState();
    _cargarUbicacionInicial();
  }

  Future<void> _cargarUbicacionInicial() async {
    final pos = await LocationService.getCurrentPosition();
    if (mounted && pos != null) {
      setState(() => _ubicacionPin = LatLng(pos.latitude, pos.longitude));
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _vestimentaController.dispose();
    _ultimaVistaController.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto(ImageSource source) async {
    try {
      final bytes = source == ImageSource.camera
          ? await FotoService.pickFromCamera()
          : await FotoService.pickFromGallery();
      if (bytes != null && mounted) {
        setState(() => _fotoBytes = bytes);
      }
    } on FotoValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(ctx);
                _elegirFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(ctx);
                _elegirFoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarResultadoEmision({
    required String alertaId,
    required PushDispatchResult push,
    required int radioKm,
  }) async {
    final alerta = await AlertaService.fetchById(alertaId);
    if (!mounted) return;

    final sent = push.sent;
    final ok = push.ok;

    String mensaje;
    if (!ok) {
      mensaje =
          'Alerta publicada, pero no pudimos confirmar las notificaciones push. '
          'Comparte por WhatsApp para llegar a más gente.';
    } else if (sent > 0) {
      mensaje =
          'Se notificó a $sent ${sent == 1 ? 'persona' : 'personas'} '
          'en un radio de $radioKm km.';
    } else {
      mensaje =
          'Nadie con la app activa está cerca ($radioKm km). '
          'Comparte por WhatsApp para amplificar la alerta.';
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alerta enviada'),
        content: Text(mensaje),
        actions: [
          if (alerta != null && (sent == 0 || !ok))
            TextButton(
              onPressed: () async {
                await ShareService.compartirWhatsApp(alerta);
              },
              child: const Text('Difundir en WhatsApp'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _enviar() async {
    if (_fotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fotografía es obligatoria')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (_ubicacionPin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marca en el mapa la última ubicación vista')),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final fotoUrl = await FotoService.uploadAlertaFoto(_fotoBytes!);
      final nombre = _nombreController.text.trim();
      final edad = int.parse(_edadController.text);
      final ultimaVista = _ultimaVistaController.text.trim();
      final alertaId = await AlertaService.crearAlerta(
        nombrePersona: nombre,
        edadAprox: edad,
        vestimenta: _vestimentaController.text.trim(),
        fotoUrl: fotoUrl,
        lat: _ubicacionPin!.latitude,
        lng: _ubicacionPin!.longitude,
        ultimaVistaTexto: ultimaVista,
        radioKm: _radioKm,
      );
      final push = await PushService.notificarUsuariosCercanos(
        alertaId: alertaId,
        lat: _ubicacionPin!.latitude,
        lng: _ubicacionPin!.longitude,
        nombrePersona: nombre,
        radioKm: _radioKm,
        edadAprox: edad,
        ultimaVistaTexto: ultimaVista,
      );

      if (!mounted) return;
      await _mostrarResultadoEmision(
        alertaId: alertaId,
        push: push,
        radioKm: _radioKm,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFacingError(e)),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text('Reportar Desaparición'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(CentinelaSpacing.lg),
          children: [
            _UploadPhotoArea(
              fotoBytes: _fotoBytes,
              onTap: _enviando ? null : _mostrarOpcionesFoto,
            ),
            const SizedBox(height: CentinelaSpacing.lg),
            TextFormField(
              controller: _nombreController,
              enabled: !_enviando,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: CentinelaSpacing.md),
            TextFormField(
              controller: _edadController,
              enabled: !_enviando,
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
              enabled: !_enviando,
              decoration: const InputDecoration(
                labelText: 'Vestimenta o rasgo particular',
                hintText: 'Ej: Camiseta roja, cicatriz en el brazo',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: CentinelaSpacing.lg),
            CentinelaSectionHeader(
              title: 'Última ubicación vista',
              subtitle: 'Describe el lugar y marca el punto en el mapa',
              icon: Icons.place_outlined,
            ),
            const SizedBox(height: CentinelaSpacing.sm),
            TextFormField(
              controller: _ultimaVistaController,
              enabled: !_enviando,
              decoration: const InputDecoration(
                labelText: 'Descripción del lugar (texto libre)',
                hintText: 'Ej: Se la vio saliendo del mercado, iba hacia el norte',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: CentinelaSpacing.md),
            UbicacionPinPicker(
              position: _ubicacionPin,
              enabled: !_enviando,
              height: 200,
              onChanged: (sel) => setState(() => _ubicacionPin = sel.point),
            ),
            const SizedBox(height: CentinelaSpacing.lg),
            CentinelaSectionHeader(
              title: 'Radio de notificación',
              subtitle: 'A quién avisar en la comunidad',
              icon: Icons.radar,
            ),
            const SizedBox(height: CentinelaSpacing.sm),
            SegmentedButton<int>(
              segments: _radiosDisponibles
                  .map((km) => ButtonSegment(value: km, label: Text('$km km')))
                  .toList(),
              selected: {_radioKm},
              onSelectionChanged: _enviando
                  ? null
                  : (sel) => setState(() => _radioKm = sel.first),
            ),
            const SizedBox(height: CentinelaSpacing.sm),
            Text(
              'Jipijapa urbano: 10 km. Rural o carretera: 30 km. '
              'Provincia (máx. app): 50 km. Para más alcance, usa WhatsApp.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CentinelaColors.textSecondary,
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
            onPressed: _enviando ? null : _enviar,
            child: _enviando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('ENVIAR ALERTA A LA COMUNIDAD'),
          ),
        ),
      ),
    );
  }
}

class _UploadPhotoArea extends StatelessWidget {
  const _UploadPhotoArea({required this.fotoBytes, required this.onTap});

  final Uint8List? fotoBytes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = fotoBytes != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: hasPhoto ? 220 : 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: CentinelaColors.surface,
          borderRadius: BorderRadius.circular(CentinelaSpacing.radiusLg),
          border: Border.all(
            color: hasPhoto ? CentinelaColors.community : CentinelaColors.border,
            width: hasPhoto ? 2 : 1.5,
          ),
          boxShadow: hasPhoto
              ? [
                  BoxShadow(
                    color: CentinelaColors.community.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          image: fotoBytes != null
              ? DecorationImage(image: MemoryImage(fotoBytes!), fit: BoxFit.cover)
              : null,
        ),
        child: fotoBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CentinelaColors.community.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      size: 36,
                      color: CentinelaColors.community,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Subir fotografía',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Toca para cámara o galería · Se comprime automáticamente',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CentinelaColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : null,
        ),
      ),
    );
  }
}
