import '../models/alerta_desaparecido.dart';

/// Filtros de distancia y antigüedad para el mapa/lista (Sprint 8).
enum FiltroDistanciaKm {
  sinLimite(0),
  km5(5),
  km10(10),
  km30(30);

  const FiltroDistanciaKm(this.km);
  final int km;

  String get etiqueta => switch (this) {
        FiltroDistanciaKm.sinLimite => 'Todas',
        FiltroDistanciaKm.km5 => '5 km',
        FiltroDistanciaKm.km10 => '10 km',
        FiltroDistanciaKm.km30 => '30 km',
      };
}

enum FiltroAntiguedad {
  todas(0),
  h1(60),
  h24(24 * 60);

  const FiltroAntiguedad(this.minutosMax);
  final int minutosMax;

  String get etiqueta => switch (this) {
        FiltroAntiguedad.todas => 'Todas',
        FiltroAntiguedad.h1 => '1 h',
        FiltroAntiguedad.h24 => '24 h',
      };
}

List<AlertaDesaparecido> aplicarFiltrosAlertas(
  List<AlertaDesaparecido> alertas, {
  required FiltroDistanciaKm distancia,
  required FiltroAntiguedad antiguedad,
}) {
  return alertas.where((a) {
    if (distancia != FiltroDistanciaKm.sinLimite &&
        a.distanciaKm > distancia.km) {
      return false;
    }
    if (antiguedad != FiltroAntiguedad.todas &&
        a.minutosReportada > antiguedad.minutosMax) {
      return false;
    }
    return true;
  }).toList();
}
