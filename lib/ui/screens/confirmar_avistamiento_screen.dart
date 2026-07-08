import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../services/avistamiento_service.dart';
import '../../services/push_service.dart';
import '../../services/location_service.dart';
import '../../utils/user_facing_error.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';
import '../widgets/ubicacion_pin_picker.dart';

/// Confirmar «Lo vi» con pin en mapa (Sprint 5).
class ConfirmarAvistamientoScreen extends StatefulWidget {
  const ConfirmarAvistamientoScreen({
    super.key,
    required this.alertaId,
    required this.alertaLat,
    required this.alertaLng,
  });

  final String alertaId;
  final double alertaLat;
  final double alertaLng;

  @override
  State<ConfirmarAvistamientoScreen> createState() =>
      _ConfirmarAvistamientoScreenState();
}

class _ConfirmarAvistamientoScreenState extends State<ConfirmarAvistamientoScreen> {
  LatLng? _ubicacion;
  String? _etiquetaLugar;
  final _notaController = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (_ubicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marca en el mapa dónde lo viste')),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      await LocationService.syncUbicacionToSupabase();
      await AvistamientoService.registrarLoVi(
        widget.alertaId,
        lat: _ubicacion!.latitude,
        lng: _ubicacion!.longitude,
        notaTestigo: _notaController.text.trim().isEmpty
            ? null
            : _notaController.text.trim(),
        ubicacionTexto: _etiquetaLugar,
      );
      final distanciaKm = const Distance().as(
        LengthUnit.Kilometer,
        LatLng(widget.alertaLat, widget.alertaLng),
        _ubicacion!,
      );
      await PushService.notificarEmisorAvistamiento(
        alertaId: widget.alertaId,
        ubicacionTexto: _etiquetaLugar,
        distanciaKm: distanciaKm,
        notaPreview: _notaController.text.trim().isEmpty
            ? null
            : _notaController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¿Dónde lo viste?')),
      body: ListView(
        padding: const EdgeInsets.all(CentinelaSpacing.lg),
        children: [
          Text(
            'Marca el punto en el mapa. Puedes usar tu GPS o tocar otro lugar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CentinelaColors.textSecondary,
            ),
          ),
          const SizedBox(height: CentinelaSpacing.lg),
          UbicacionPinPicker(
            position: _ubicacion,
            enabled: !_enviando,
            height: 280,
            onChanged: (sel) => setState(() {
              _ubicacion = sel.point;
              _etiquetaLugar = sel.etiquetaLugar;
            }),
          ),
          const SizedBox(height: CentinelaSpacing.md),
          TextField(
            controller: _notaController,
            enabled: !_enviando,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Detalle (opcional)',
              hintText: 'Ej: Iba caminando hacia el mercado, llevaba mochila azul',
            ),
          ),
          const SizedBox(height: CentinelaSpacing.lg),
          FilledButton(
            onPressed: _enviando ? null : _confirmar,
            style: FilledButton.styleFrom(
              backgroundColor: CentinelaColors.community,
              minimumSize: const Size(double.infinity, 52),
            ),
            child: _enviando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('CONFIRMAR AVISTAMIENTO'),
          ),
        ],
      ),
    );
  }
}
