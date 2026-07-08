import 'package:centinela/utils/distancia_formato.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DistanciaFormato', () {
    test('muy cerca cuando distancia < 0.05 km', () {
      expect(DistanciaFormato.desdeUsuario(0), 'Muy cerca de ti');
      expect(DistanciaFormato.desdeUsuario(0.04), 'Muy cerca de ti');
    });

    test('formato corto para distancias menores a 5 km', () {
      expect(DistanciaFormato.desdeUsuario(1.2), 'A 1.2 km de ti');
      expect(DistanciaFormato.desdeUsuario(4.9), 'A 4.9 km de ti');
    });

    test('incluye estimado carretera para distancias >= 5 km', () {
      expect(
        DistanciaFormato.desdeUsuario(10),
        'A ~13 km de ti (≈10.0 km en línea recta)',
      );
    });

    test('factor carretera es 1.3', () {
      expect(DistanciaFormato.factorCarretera, 1.3);
    });
  });
}
