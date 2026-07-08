import 'package:url_launcher/url_launcher.dart';

import '../config/app_env.dart';
import '../models/alerta_desaparecido.dart';
import 'compartir_service.dart';
import 'deep_link_service.dart';

/// Compartir alerta por WhatsApp con enlace de preview Open Graph.
class ShareService {
  ShareService._();

  static String mensajeWhatsApp(AlertaDesaparecido alerta) {
    final link = AppEnv.alertaPreviewUrl(alerta.id);
    final lugar = alerta.ultimaVistaTexto.isNotEmpty
        ? '\nÚltimo lugar visto: ${alerta.ultimaVistaTexto}'
        : '';
    return '''🚨 ALERTA COMUNITARIA: PERSONA DESAPARECIDA 🚨

Nombre: ${alerta.nombrePersona}
Edad: ${alerta.edadAprox} años
Vestimenta: ${alerta.vestimenta}$lugar

🔗 Ver detalles y ayudar:
$link

📱 Abrir en Centinela:
${DeepLinkService.alertaDeepLink(alerta.id)}''';
  }

  static Future<bool> compartirWhatsApp(AlertaDesaparecido alerta) async {
    final text = Uri.encodeComponent(mensajeWhatsApp(alerta));

    final uris = [
      Uri.parse('whatsapp://send?text=$text'),
      Uri.parse('https://wa.me/?text=$text'),
    ];

    for (final uri in uris) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          await CompartirService.registrarYNotificar(alerta.id);
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }
}
