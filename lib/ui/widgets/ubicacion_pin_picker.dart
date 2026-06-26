import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/geocoding_service.dart';
import '../../services/location_service.dart';
import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Mapa interactivo para elegir un punto + búsqueda por nombre (Sprint 5).
class UbicacionPinPicker extends StatefulWidget {
  const UbicacionPinPicker({
    super.key,
    required this.position,
    required this.onChanged,
    this.height = 220,
    this.enabled = true,
    this.showSearch = true,
  });

  final LatLng? position;
  final ValueChanged<LatLng> onChanged;
  final double height;
  final bool enabled;
  final bool showSearch;

  @override
  State<UbicacionPinPicker> createState() => _UbicacionPinPickerState();
}

class _UbicacionPinPickerState extends State<UbicacionPinPicker> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  LatLng? _pin;
  bool _loadingGps = false;
  bool _searching = false;
  String? _resolvedPlaceName;

  static const _defaultCenter = GeocodingService.jipijapaCenter;

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
      _moveMapTo(_pin!, zoom: 16);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _resolvedPlaceName = 'Tu ubicación actual';
      });
      widget.onChanged(latLng);
      _moveMapTo(latLng, zoom: 16);
    } else {
      setState(() => _loadingGps = false);
    }
  }

  void _moveMapTo(LatLng point, {double zoom = 16}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(point, zoom);
    });
  }

  void _setPin(LatLng point, {String? placeName}) {
    setState(() {
      _pin = point;
      _resolvedPlaceName = placeName;
    });
    widget.onChanged(point);
    _moveMapTo(point, zoom: 16);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!widget.enabled) return;
    _setPin(point, placeName: 'Punto marcado en el mapa');
  }

  Future<void> _buscarLugar() async {
    if (!widget.enabled || _searching) return;
    final query = _searchController.text.trim();
    if (query.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe al menos 3 letras para buscar')),
      );
      return;
    }

    setState(() => _searching = true);
    FocusScope.of(context).unfocus();

    try {
      final results = await GeocodingService.search(
        query,
        near: _pin ?? _defaultCenter,
      );
      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No encontramos ese lugar. Prueba "centro de Jipijapa" o mueve el pin.',
            ),
          ),
        );
        return;
      }

      if (results.length == 1) {
        final place = results.first;
        _setPin(place.point, placeName: place.displayName);
        return;
      }

      final picked = await showModalBottomSheet<GeocodingPlace>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Elige el lugar',
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final place = results[i];
                    return ListTile(
                      leading: const Icon(
                        Icons.place_outlined,
                        color: CentinelaColors.community,
                      ),
                      title: Text(
                        place.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.pop(ctx, place),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

      if (picked != null) {
        _setPin(picked.point, placeName: picked.displayName);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar: $e')),
      );
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _pin ?? _defaultCenter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSearch) ...[
          TextField(
            controller: _searchController,
            enabled: widget.enabled && !_searching,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _buscarLugar(),
            decoration: InputDecoration(
              labelText: 'Buscar lugar en mapa',
              hintText: 'Ej: centro de Jipijapa, universidad, parque central',
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar',
                      onPressed: widget.enabled ? _buscarLugar : null,
                    ),
            ),
          ),
          const SizedBox(height: CentinelaSpacing.sm),
        ],
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
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.axeljhostin.centinela.centinela',
                    ),
                    if (_pin != null)
                      IgnorePointer(
                        child: MarkerLayer(
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
              ? 'Busca un lugar o toca el mapa para marcar el pin'
              : _resolvedPlaceName ??
                    'Lat ${_pin!.latitude.toStringAsFixed(5)}, Lng ${_pin!.longitude.toStringAsFixed(5)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: CentinelaColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
