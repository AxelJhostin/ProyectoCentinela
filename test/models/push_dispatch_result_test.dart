import 'package:centinela/models/push_dispatch_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushDispatchResult', () {
    test('fromResponse parsea respuesta exitosa', () {
      final result = PushDispatchResult.fromResponse({
        'ok': true,
        'sent': 8,
        'total': 10,
        'message': 'Enviado',
      });

      expect(result.ok, isTrue);
      expect(result.sent, 8);
      expect(result.total, 10);
      expect(result.message, 'Enviado');
    });

    test('fromResponse maneja campos faltantes', () {
      final result = PushDispatchResult.fromResponse({'ok': false});

      expect(result.ok, isFalse);
      expect(result.sent, 0);
      expect(result.total, 0);
      expect(result.message, isNull);
    });

    test('fromResponse rechaza datos no-map', () {
      final result = PushDispatchResult.fromResponse('error');

      expect(result.ok, isFalse);
      expect(result.message, 'Respuesta inválida del servidor');
    });
  });
}
