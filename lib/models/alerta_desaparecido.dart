/// Alerta de persona desaparecida (modelo de dominio MVP).
class AlertaDesaparecido {
  const AlertaDesaparecido({
    required this.id,
    required this.nombrePersona,
    required this.edadAprox,
    required this.vestimenta,
    required this.distanciaKm,
    required this.minutosReportada,
    required this.latitud,
    required this.longitud,
    this.fotoUrl,
  });

  final String id;
  final String nombrePersona;
  final int edadAprox;
  final String vestimenta;
  final double distanciaKm;
  final int minutosReportada;
  final double latitud;
  final double longitud;
  final String? fotoUrl;

  String get distanciaTexto => 'A ${distanciaKm.toStringAsFixed(1)} km de ti';

  String get tiempoTexto => 'Alerta activa · Hace $minutosReportada min';
}
