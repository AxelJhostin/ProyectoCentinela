import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/widgets/witness_guide_dialog.dart';

/// Guía única para testigos (Sprint 6).
class WitnessGuideService {
  WitnessGuideService._();

  static const _key = 'witness_guide_seen_v1';

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
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => WitnessGuideDialog(
        onDismiss: () async {
          await markSeen();
        },
      ),
    );
  }
}
