import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Mapa comparativo: origen de alerta vs punto del avistamiento.
class AvistamientoMapaDialog extends StatelessWidget {
  const AvistamientoMapaDialog({
    super.key,
    required this.origenAlerta,
    required this.puntoAvistamiento,
    required this.titulo,
  });

  final LatLng origenAlerta;
  final LatLng puntoAvistamiento;
  final String titulo;

  static Future<void> show(
    BuildContext context, {
    required LatLng origenAlerta,
    required LatLng puntoAvistamiento,
    required String titulo,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AvistamientoMapaDialog(
        origenAlerta: origenAlerta,
        puntoAvistamiento: puntoAvistamiento,
        titulo: titulo,
      ),
    );
  }

  LatLng get _centro {
    return LatLng(
      (origenAlerta.latitude + puntoAvistamiento.latitude) / 2,
      (origenAlerta.longitude + puntoAvistamiento.longitude) / 2,
    );
  }

  double get _zoom {
    final dLat = (origenAlerta.latitude - puntoAvistamiento.latitude).abs();
    final dLng = (origenAlerta.longitude - puntoAvistamiento.longitude).abs();
    final maxDelta = dLat > dLng ? dLat : dLng;
    if (maxDelta > 0.5) return 8;
    if (maxDelta > 0.2) return 10;
    if (maxDelta > 0.05) return 12;
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo, style: const TextStyle(fontSize: 16)),
      content: SizedBox(
        width: double.maxFinite,
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: CentinelaColors.alertCritical, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Rojo: último lugar reportado',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.visibility, color: CentinelaColors.community, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Azul: donde lo vieron',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: CentinelaSpacing.sm),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _centro,
                    initialZoom: _zoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.axeljhostin.centinela.centinela',
                    ),
                    IgnorePointer(
                      child: MarkerLayer(
                        markers: [
                          Marker(
                            point: origenAlerta,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: CentinelaColors.alertCritical,
                              size: 40,
                            ),
                          ),
                          Marker(
                            point: puntoAvistamiento,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.visibility,
                              color: CentinelaColors.community,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
