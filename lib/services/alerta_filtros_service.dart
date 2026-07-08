import 'package:shared_preferences/shared_preferences.dart';

import '../utils/alerta_filtros.dart';

/// Persistencia de preferencias de filtro en Home (Sprint 8).
class AlertaFiltrosService {
  AlertaFiltrosService._();

  static const _keyDistancia = 'filtro_distancia_v1';
  static const _keyAntiguedad = 'filtro_antiguedad_v1';

  static Future<FiltroDistanciaKm> getDistancia() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_keyDistancia) ?? FiltroDistanciaKm.sinLimite.index;
    if (idx < 0 || idx >= FiltroDistanciaKm.values.length) {
      return FiltroDistanciaKm.sinLimite;
    }
    return FiltroDistanciaKm.values[idx];
  }

  static Future<FiltroAntiguedad> getAntiguedad() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_keyAntiguedad) ?? FiltroAntiguedad.todas.index;
    if (idx < 0 || idx >= FiltroAntiguedad.values.length) {
      return FiltroAntiguedad.todas;
    }
    return FiltroAntiguedad.values[idx];
  }

  static Future<void> save({
    required FiltroDistanciaKm distancia,
    required FiltroAntiguedad antiguedad,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDistancia, distancia.index);
    await prefs.setInt(_keyAntiguedad, antiguedad.index);
  }
}
