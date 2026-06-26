import 'package:url_launcher/url_launcher.dart';

import '../config/app_env.dart';
import '../models/alerta_desaparecido.dart';
import 'deep_link_service.dart';

/// Compartir alerta por WhatsApp con enlace de preview Open Graph.
class ShareService {
  ShareService._();

  static String mensajeWhatsApp(AlertaDesaparecido alerta) {
    final link = AppEnv.alertaPreviewUrl(alerta.id);
    return '''🚨 ALERTA COMUNITARIA: PERSONA DESAPARECIDA 🚨

Nombre: ${alerta.nombrePersona}
Edad: ${alerta.edadAprox} años
Vestimenta: ${alerta.vestimenta}

🔗 Ver detalles y ayudar:
$link

📱 Abrir en Centinela:
${DeepLinkService.alertaDeepLink(alerta.id)}''';
  }

  static Future<bool> compartirWhatsApp(AlertaDesaparecido alerta) async {
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(mensajeWhatsApp(alerta))}',
    );
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
