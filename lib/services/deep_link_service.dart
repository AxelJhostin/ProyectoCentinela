import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../ui/screens/detalle_alerta_screen.dart';
import 'alerta_service.dart';

/// Deep links `centinela://alerta?id=<uuid>` (Sprint 3).
class DeepLinkService {
  DeepLinkService._();

  static final _appLinks = AppLinks();
  static GlobalKey<NavigatorState>? _navigatorKey;

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      await _handleUri(initial);
    }

    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  static String alertaDeepLink(String alertaId) =>
      'centinela://alerta?id=$alertaId';

  static Future<void> _handleUri(Uri uri) async {
    final alertaId = _extractAlertaId(uri);
    if (alertaId == null) return;

    final alerta = await AlertaService.fetchById(alertaId);
    if (alerta == null) return;

    final nav = _navigatorKey?.currentState;
    if (nav == null) return;

    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => DetalleAlertaScreen(alerta: alerta),
      ),
    );
  }

  static String? _extractAlertaId(Uri uri) {
    if (uri.scheme != 'centinela') return null;
    if (uri.host != 'alerta') return null;

    final fromQuery = uri.queryParameters['id'];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;

    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first.isNotEmpty) {
      return uri.pathSegments.first;
    }
    return null;
  }
}
