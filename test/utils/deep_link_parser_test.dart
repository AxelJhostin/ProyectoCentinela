import 'package:centinela/utils/deep_link_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAlertaIdFromUri', () {
    const alertaId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

    test('extrae id desde query parameter', () {
      final uri = Uri.parse('centinela://alerta?id=$alertaId');
      expect(parseAlertaIdFromUri(uri), alertaId);
    });

    test('extrae id desde path segment', () {
      final uri = Uri.parse('centinela://alerta/$alertaId');
      expect(parseAlertaIdFromUri(uri), alertaId);
    });

    test('rechaza esquema incorrecto', () {
      final uri = Uri.parse('https://alerta?id=$alertaId');
      expect(parseAlertaIdFromUri(uri), isNull);
    });

    test('rechaza host incorrecto', () {
      final uri = Uri.parse('centinela://home?id=$alertaId');
      expect(parseAlertaIdFromUri(uri), isNull);
    });

    test('rechaza uri sin id', () {
      final uri = Uri.parse('centinela://alerta');
      expect(parseAlertaIdFromUri(uri), isNull);
    });
  });
}
