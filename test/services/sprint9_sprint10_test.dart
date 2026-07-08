import 'package:centinela/models/alerta_desaparecido.dart';
import 'package:centinela/services/cache_service.dart';
import 'package:centinela/utils/user_facing_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CacheService', () {
    test('guarda y lee alertas activas', () async {
      final alertas = [buildSampleAlerta()];
      await CacheService.guardarAlertasActivas(alertas);

      final cache = await CacheService.leerAlertasActivas();
      expect(cache, isNotNull);
      expect(cache!.alertas.length, 1);
      expect(cache.alertas.first.nombrePersona, 'María López');
    });

    test('guarda y lee detalle de alerta', () async {
      final alerta = buildSampleAlerta();
      await CacheService.guardarDetalle(alerta);

      final cached = await CacheService.leerDetalle();
      expect(cached?.id, sampleAlertaId);
    });
  });

  group('userFacingError sprint9', () {
    test('traduce cooldown de emisión', () {
      final msg = userFacingError(
        Exception('Espera 15 minutos después de resolver'),
      );
      expect(msg, contains('15 minutos'));
    });

    test('traduce límite de avistamientos', () {
      final msg = userFacingError(
        Exception('muchos avistamientos en la última hora'),
      );
      expect(msg, contains('avistamientos'));
    });
  });

  group('AlertaDesaparecido estado', () {
    test('tiempoTexto para resuelta', () {
      final alerta = buildSampleAlerta();
      final resuelta = AlertaDesaparecido(
        id: alerta.id,
        emisorId: alerta.emisorId,
        nombrePersona: alerta.nombrePersona,
        edadAprox: alerta.edadAprox,
        vestimenta: alerta.vestimenta,
        distanciaKm: alerta.distanciaKm,
        minutosReportada: alerta.minutosReportada,
        latitud: alerta.latitud,
        longitud: alerta.longitud,
        fotoUrl: alerta.fotoUrl,
        radioKm: alerta.radioKm,
        creadoEn: alerta.creadoEn,
        estado: 'RESUELTA',
      );
      expect(resuelta.tiempoTexto, 'Caso resuelto');
    });
  });
}
