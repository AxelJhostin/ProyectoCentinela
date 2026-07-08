import 'package:centinela/utils/alerta_filtros.dart';
import 'package:centinela/utils/foto_validacion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('aplicarFiltrosAlertas', () {
    test('filtra por distancia', () {
      final alertas = [
        buildSampleAlerta(distanciaKm: 2),
        buildSampleAlerta(distanciaKm: 15),
      ];
      final filtradas = aplicarFiltrosAlertas(
        alertas,
        distancia: FiltroDistanciaKm.km10,
        antiguedad: FiltroAntiguedad.todas,
      );
      expect(filtradas.length, 1);
      expect(filtradas.first.distanciaKm, 2);
    });

    test('filtra por antigüedad', () {
      final alertas = [
        buildSampleAlerta(minutosReportada: 30),
        buildSampleAlerta(minutosReportada: 120),
      ];
      final filtradas = aplicarFiltrosAlertas(
        alertas,
        distancia: FiltroDistanciaKm.sinLimite,
        antiguedad: FiltroAntiguedad.h1,
      );
      expect(filtradas.length, 1);
      expect(filtradas.first.minutosReportada, 30);
    });
  });

  group('FotoValidacion', () {
    test('rechaza archivos muy grandes', () {
      expect(
        FotoValidacion.validarTamanoBytes(11 * 1024 * 1024),
        isNotNull,
      );
    });

    test('acepta tamaño válido', () {
      expect(FotoValidacion.validarTamanoBytes(1024), isNull);
    });

    test('rechaza dimensiones pequeñas', () {
      expect(
        FotoValidacion.validarDimensiones(ancho: 100, alto: 300),
        isNotNull,
      );
    });
  });
}
