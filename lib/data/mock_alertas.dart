import '../models/alerta_desaparecido.dart';

/// Datos de prueba Sprint 1 — Jipijapa aprox. (-1.0, -80.58).
abstract final class MockAlertas {
  static const centroLat = -1.0;
  static const centroLng = -80.5833;

  static const alertas = [
    AlertaDesaparecido(
      id: 'mock-1',
      nombrePersona: 'María Elena Ruiz',
      edadAprox: 34,
      vestimenta:
          'Chamarra azul marino, jeans oscuros, tenis blancos. '
          'Llevaba mochila negra y gorra gris.',
      distanciaKm: 1.2,
      minutosReportada: 8,
      latitud: -1.008,
      longitud: -80.575,
    ),
    AlertaDesaparecido(
      id: 'mock-2',
      nombrePersona: 'Carlos Andrés Mero',
      edadAprox: 17,
      vestimenta: 'Camiseta roja del colegio, pantalón caqui.',
      distanciaKm: 2.4,
      minutosReportada: 22,
      latitud: -0.992,
      longitud: -80.591,
    ),
  ];

  static AlertaDesaparecido? byId(String id) {
    for (final alerta in alertas) {
      if (alerta.id == id) return alerta;
    }
    return null;
  }
}
