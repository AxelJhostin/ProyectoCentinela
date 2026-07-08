import 'package:centinela/models/alerta_desaparecido.dart';

const sampleAlertaId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
const sampleEmisorId = 'e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1';

AlertaDesaparecido buildSampleAlerta({
  String id = sampleAlertaId,
  String nombrePersona = 'María López',
  int edadAprox = 14,
  String vestimenta = 'Camiseta azul, jeans',
  String ultimaVistaTexto = 'Mercado central de Jipijapa',
  double distanciaKm = 2.4,
  int minutosReportada = 5,
  double latitud = -1.0036,
  double longitud = -80.5789,
  String fotoUrl = 'https://example.com/foto.jpg',
  int radioKm = 10,
  DateTime? creadoEn,
}) {
  return AlertaDesaparecido(
    id: id,
    emisorId: sampleEmisorId,
    nombrePersona: nombrePersona,
    edadAprox: edadAprox,
    vestimenta: vestimenta,
    ultimaVistaTexto: ultimaVistaTexto,
    distanciaKm: distanciaKm,
    minutosReportada: minutosReportada,
    latitud: latitud,
    longitud: longitud,
    fotoUrl: fotoUrl,
    radioKm: radioKm,
    creadoEn: creadoEn ?? DateTime(2026, 6, 15, 10, 0),
  );
}

Map<String, dynamic> buildAlertaMap({
  String id = sampleAlertaId,
  String nombrePersona = 'María López',
  int edadAprox = 14,
  String vestimenta = 'Camiseta azul',
  String ultimaVistaTexto = 'Parque central',
  double lat = -1.0036,
  double lng = -80.5789,
  String fotoUrl = 'https://example.com/foto.jpg',
  int radioKm = 10,
  String creadoEn = '2026-06-15T15:00:00.000Z',
}) {
  return {
    'id': id,
    'emisor_id': sampleEmisorId,
    'nombre_persona': nombrePersona,
    'edad_aprox': edadAprox,
    'vestimenta': vestimenta,
    'ultima_vista_texto': ultimaVistaTexto,
    'lat': lat,
    'lng': lng,
    'foto_url': fotoUrl,
    'radio_km': radioKm,
    'creado_en': creadoEn,
  };
}
