/// Utilidades de distancia para la UI (línea recta + estimado carretera).
abstract final class DistanciaFormato {
  /// Factor típico carretera / línea recta en zona rural Manabí.
  static const factorCarretera = 1.3;

  static String desdeUsuario(double distanciaKm) {
    if (distanciaKm < 0.05) return 'Muy cerca de ti';
    final recta = distanciaKm.toStringAsFixed(1);
    if (distanciaKm >= 5) {
      final carretera = (distanciaKm * factorCarretera).round();
      return 'A ~$carretera km de ti (≈$recta km en línea recta)';
    }
    return 'A $recta km de ti';
  }
}
