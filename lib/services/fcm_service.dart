import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import 'alerta_service.dart';
import 'supabase_service.dart';
import '../ui/screens/detalle_alerta_screen.dart';

/// Handler en segundo plano (obligatorio top-level).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Firebase Cloud Messaging — tokens + notificaciones (Sprint 5.2).
class FcmService {
  FcmService._();

  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'centinela_alertas';

  static Future<void> init() async {
    if (kIsWeb) return;

    try {
      await Firebase.initializeApp();

      if (Platform.isAndroid) {
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        await _localNotifications.initialize(
          const InitializationSettings(android: androidInit),
          onDidReceiveNotificationResponse: (response) {
            final payload = response.payload;
            if (payload != null && payload.isNotEmpty) {
              _openAlerta(payload);
            }
          },
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                _channelId,
                'Alertas Centinela',
                description: 'Notificaciones de desapariciones cercanas',
                importance: Importance.high,
              ),
            );
      }

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      final token = await messaging.getToken();
      if (token != null) await saveToken(token);
      messaging.onTokenRefresh.listen(saveToken);

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      final initial = await messaging.getInitialMessage();
      if (initial != null) await _handleMessage(initial);

      debugPrint('FCM inicializado. Token: ${token != null ? "ok" : "pendiente"}');
    } catch (e) {
      debugPrint(
        'FCM no disponible (¿falta google-services.json?): $e',
      );
    }
  }

  static Future<void> saveToken(String token) async {
    if (SupabaseService.client.auth.currentUser == null) return;
    await SupabaseService.client.rpc<void>(
      'actualizar_fcm_token',
      params: {'p_token': token},
    );
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!Platform.isAndroid) return;
    final notification = message.notification;
    final alertaId = message.data['alerta_id'];
    await _localNotifications.show(
      message.hashCode,
      notification?.title ?? 'Centinela',
      notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Alertas Centinela',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: alertaId,
    );
  }

  static Future<void> _handleMessage(RemoteMessage message) async {
    final alertaId = message.data['alerta_id'];
    if (alertaId != null && alertaId.isNotEmpty) {
      await _openAlerta(alertaId);
    }
  }

  static Future<void> _openAlerta(String alertaId) async {
    final alerta = await AlertaService.fetchById(alertaId);
    if (alerta == null) return;
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => DetalleAlertaScreen(alerta: alerta),
      ),
    );
  }
}
