import 'package:centinela/utils/user_facing_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('userFacingError', () {
    test('traduce límite de cuenta nueva', () {
      final msg = userFacingError(
        Exception('Cuentas nuevas: máximo 3 alertas en 24h'),
      );
      expect(msg, contains('cuenta es nueva'));
    });

    test('traduce alerta activa existente', () {
      final msg = userFacingError(
        Exception('Ya tienes una alerta activa'),
      );
      expect(msg, contains('alerta activa'));
    });

    test('traduce perfil no encontrado', () {
      final msg = userFacingError(
        Exception('Perfil de usuario no encontrado'),
      );
      expect(msg, contains('perfil'));
    });

    test('extrae mensaje de error Postgres', () {
      final msg = userFacingError(
        Exception('PostgrestException(message: Radio inválido, code: P0001)'),
      );
      expect(msg, 'Radio inválido');
    });

    test('mensaje genérico para errores desconocidos', () {
      final msg = userFacingError(Exception('algo inesperado'));
      expect(msg, 'No se pudo completar la acción. Intenta de nuevo.');
    });
  });
}
