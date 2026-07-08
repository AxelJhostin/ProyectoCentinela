import 'package:centinela/models/alerta_desaparecido.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('AlertaDesaparecido', () {
    test('fromMap parsea campos y calcula distancia con GPS del usuario', () {
      final alerta = AlertaDesaparecido.fromMap(
        buildAlertaMap(),
        userLat: -1.01,
        userLng: -80.58,
      );

      expect(alerta.id, sampleAlertaId);
      expect(alerta.nombrePersona, 'María López');
      expect(alerta.edadAprox, 14);
      expect(alerta.vestimenta, 'Camiseta azul');
      expect(alerta.ultimaVistaTexto, 'Parque central');
      expect(alerta.radioKm, 10);
      expect(alerta.distanciaKm, greaterThan(0));
    });

    test('fromMap sin GPS deja distancia en 0', () {
      final alerta = AlertaDesaparecido.fromMap(buildAlertaMap());
      expect(alerta.distanciaKm, 0);
    });

    test('distanciaTexto usa formateador', () {
      final alerta = buildSampleAlerta(distanciaKm: 0.02);
      expect(alerta.distanciaTexto, 'Muy cerca de ti');
    });

    test('tiempoTexto para minutos recientes', () {
      expect(buildSampleAlerta(minutosReportada: 0).tiempoTexto,
          'Alerta activa · Hace un momento');
      expect(buildSampleAlerta(minutosReportada: 1).tiempoTexto,
          'Alerta activa · Hace 1 min');
      expect(buildSampleAlerta(minutosReportada: 12).tiempoTexto,
          'Alerta activa · Hace 12 min');
    });
  });
}
