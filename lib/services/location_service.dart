import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'supabase_service.dart';

/// Ubicación GPS del dispositivo y sync con Supabase.
class LocationService {
  LocationService._();

  static Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  static Future<bool> ensureServiceEnabled() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<Position?> getCurrentPosition() async {
    final ok = await ensureServiceEnabled();
    if (!ok) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  static Future<void> syncUbicacionToSupabase() async {
    final pos = await getCurrentPosition();
    if (pos == null) return;
    await SupabaseService.client.rpc<void>(
      'actualizar_mi_ubicacion',
      params: {'p_lat': pos.latitude, 'p_lng': pos.longitude},
    );
  }
}

/// Permisos de notificaciones (FCM en Sprint 3; aquí solo se solicitan).
class NotificationPermissionService {
  NotificationPermissionService._();

  static Future<bool> request() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
