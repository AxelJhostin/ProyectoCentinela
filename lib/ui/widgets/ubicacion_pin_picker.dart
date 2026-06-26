import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/location_service.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Mapa interactivo para elegir un punto (Sprint 5).
class UbicacionPinPicker extends StatefulWidget {
  const UbicacionPinPicker({
    super.key,
    required this.position,
    required this.onChanged,
    this.height = 220,
    this.enabled = true,
  });

  final LatLng? position;
  final ValueChanged<LatLng> onChanged;
  final double height;
  final bool enabled;

  @override
  State<UbicacionPinPicker> createState() => _UbicacionPinPickerState();
}

class _UbicacionPinPickerState extends State<UbicacionPinPicker> {
  final _mapController = MapController();
  LatLng? _pin;
  bool _loadingGps = false;

  static const _defaultCenter = LatLng(-1.34885, -80.57934);

  @override
  void initState() {
    super.initState();
    _pin = widget.position;
    if (_pin == null) {
      _loadGps();
    }
  }

  @override
  void didUpdateWidget(covariant UbicacionPinPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.position != oldWidget.position && widget.position != null) {
      _pin = widget.position;
      _moveMapTo(_pin!);
    }
  }

  Future<void> _loadGps() async {
    setState(() => _loadingGps = true);
    final pos = await LocationService.getCurrentPosition();
    if (!mounted) return;
    if (pos != null) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _pin = latLng;
        _loadingGps = false;
      });
      widget.onChanged(latLng);
      _moveMapTo(latLng);
    } else {
      setState(() => _loadingGps = false);
    }
  }

  void _moveMapTo(LatLng point) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(point, _mapController.camera.zoom);
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!widget.enabled) return;
    setState(() => _pin = point);
    widget.onChanged(point);
  }

  @override
  Widget build(BuildContext context) {
    final center = _pin ?? _defaultCenter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15,
                    onTap: _onMapTap,
                    interactionOptions: InteractionOptions(
                      flags: widget.enabled ? InteractiveFlag.all : InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.axeljhostin.centinela',
                    ),
                    if (_pin != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pin!,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.location_on,
                              color: CentinelaColors.alertCritical,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_loadingGps)
                  const ColoredBox(
                    color: Colors.black26,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: CentinelaColors.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: widget.enabled && !_loadingGps ? _loadGps : null,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location, size: 18, color: CentinelaColors.community),
                            SizedBox(width: 6),
                            Text('Mi GPS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _pin == null
              ? 'Toca el mapa para marcar el lugar'
              : 'Lat ${_pin!.latitude.toStringAsFixed(5)}, Lng ${_pin!.longitude.toStringAsFixed(5)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: CentinelaColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
