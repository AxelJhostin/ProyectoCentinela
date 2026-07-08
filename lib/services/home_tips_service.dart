import 'package:flutter/material.dart';

import '../../config/app_env.dart';
import '../../services/user_role_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tips contextuales la primera vez en Home (Sprint 8).
class HomeTipsService {
  HomeTipsService._();

  static const _key = 'home_tips_seen_v1';

  static Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> showIfNeeded(BuildContext context) async {
    if (await hasSeen()) return;
    if (!context.mounted) return;
    final modo = await UserRoleService.getModo();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cómo ayudar?'),
        content: Text(
          modo == ModoUsuario.testigo
              ? '• Si recibes un push rojo, tócalo para ver el detalle.\n'
                  '• Puedes reportar «Lo vi» sin dar tu teléfono.\n'
                  '• Invita vecinos desde Acerca → compartir el sitio web.'
              : '• Si recibes un push rojo, tócalo para ver el detalle.\n'
                  '• Puedes reportar «Lo vi» sin dar tu teléfono.\n'
                  '• El botón rojo del mapa emite una alerta de emergencia.',
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              await markSeen();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
