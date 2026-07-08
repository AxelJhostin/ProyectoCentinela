import 'package:flutter/material.dart';

import '../theme/centinela_spacing.dart';
import '../theme/centinela_theme.dart';

/// Términos y consentimiento LOPDP (Sprint 4).
class LegalTermsScreen extends StatelessWidget {
  const LegalTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Términos y privacidad')),
      body: ListView(
        padding: const EdgeInsets.all(CentinelaSpacing.lg),
        children: [
          Text(
            'Centinela — Uso responsable',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: CentinelaSpacing.lg),
          _Section(
            title: '1. Propósito',
            body:
                'Centinela es una herramienta comunitaria para reportar desapariciones '
                'de forma rápida y local. No reemplaza a la Policía Nacional ni a '
                'autoridades competentes.',
          ),
          _Section(
            title: '2. Uso permitido',
            body:
                'Solo debes emitir alertas cuando exista una situación real de '
                'desaparición o riesgo inmediato. Las alertas falsas pueden ser '
                'reportadas por la comunidad y restringir tu cuenta.',
          ),
          _Section(
            title: '3. Datos personales (LOPDP — Ecuador)',
            body:
                'Recopilamos ubicación aproximada, fotografías que tú subes y un '
                'identificador anónimo de dispositivo para enviar alertas en tu zona. '
                'No publicamos tu número de teléfono ni datos de contacto directo. '
                'Puedes solicitar la eliminación de tu cuenta escribiendo al '
                'responsable del piloto.',
          ),
          _Section(
            title: '4. Ubicación',
            body:
                'La app usa GPS para calcular distancias, registrar avistamientos y '
                'notificar a usuarios cercanos. Puedes denegar el permiso, pero '
                'algunas funciones no estarán disponibles.',
          ),
          _Section(
            title: '5. Imágenes',
            body:
                'Al subir una fotografía confirmas que tienes derecho a usarla y '
                'que corresponde a la persona reportada. Las imágenes se comprimen '
                'antes de subirse al servidor.',
          ),
          _Section(
            title: '6. Limitación de responsabilidad',
            body:
                'Centinela es un MVP en fase piloto. No garantizamos la exactitud '
                'de los reportes ni la disponibilidad continua del servicio.',
          ),
          const SizedBox(height: CentinelaSpacing.md),
          Container(
            padding: const EdgeInsets.all(CentinelaSpacing.md),
            decoration: BoxDecoration(
              color: CentinelaColors.community.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
              border: Border.all(color: CentinelaColors.community.withValues(alpha: 0.4)),
            ),
            child: Text(
              'Versión piloto · Jipijapa 2025. Política completa en '
              'proyecto-centinela.vercel.app/privacidad. Este texto será revisado por '
              'asesoría legal antes del despliegue público.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CentinelaColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CentinelaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
