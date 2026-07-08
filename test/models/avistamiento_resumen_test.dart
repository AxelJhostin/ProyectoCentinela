import 'package:centinela/services/avistamiento_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AvistamientoResumen', () {
    test('fromMap parsea campos del RPC', () {
      final resumen = AvistamientoResumen.fromMap({
        'distancia_km': 3.5,
        'hace_minutos': 7,
        'lat': -1.0036,
        'lng': -80.5789,
        'nota_testigo': 'Iba caminando hacia el mercado',
        'ubicacion_texto': 'Calle 10 de Agosto, Jipijapa',
      });

      expect(resumen.distanciaKm, 3.5);
      expect(resumen.haceMinutos, 7);
      expect(resumen.notaTestigo, contains('mercado'));
      expect(resumen.ubicacionTexto, contains('Jipijapa'));
    });

    test('lugarDisplay prioriza ubicacionTexto', () {
      final resumen = AvistamientoResumen(
        distanciaKm: 2,
        haceMinutos: 1,
        lat: -1.0,
        lng: -80.5,
        ubicacionTexto: 'Mercado central',
        lugarResuelto: 'Otro lugar',
      );
      expect(resumen.lugarDisplay, 'Mercado central');
    });

    test('lugarDisplay acorta textos largos', () {
      final largo = 'A' * 80;
      final resumen = AvistamientoResumen(
        distanciaKm: 2,
        haceMinutos: 1,
        lat: -1.0,
        lng: -80.5,
        ubicacionTexto: largo,
      );
      expect(resumen.lugarDisplay.length, 68);
      expect(resumen.lugarDisplay.endsWith('…'), isTrue);
    });

    test('tiempoTexto formatea minutos', () {
      expect(
        AvistamientoResumen(distanciaKm: 1, haceMinutos: 0, lat: 0, lng: 0)
            .tiempoTexto,
        'hace un momento',
      );
      expect(
        AvistamientoResumen(distanciaKm: 1, haceMinutos: 1, lat: 0, lng: 0)
            .tiempoTexto,
        'hace 1 min',
      );
      expect(
        AvistamientoResumen(distanciaKm: 1, haceMinutos: 15, lat: 0, lng: 0)
            .tiempoTexto,
        'hace 15 min',
      );
    });

    test('lineaPrincipal combina lugar, distancia y tiempo', () {
      final resumen = AvistamientoResumen(
        distanciaKm: 4.2,
        haceMinutos: 3,
        lat: -1.0,
        lng: -80.5,
        ubicacionTexto: 'Parque',
      );
      expect(resumen.lineaPrincipal, contains('Visto cerca de: Parque'));
      expect(resumen.lineaPrincipal, contains('4.2 km'));
      expect(resumen.lineaPrincipal, contains('hace 3 min'));
    });
  });
}
