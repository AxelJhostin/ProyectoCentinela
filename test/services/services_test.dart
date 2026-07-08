import 'package:centinela/services/deep_link_service.dart';
import 'package:centinela/services/onboarding_service.dart';
import 'package:centinela/services/share_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_env.dart';

void main() {
  group('OnboardingService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isCompleted es false al inicio', () async {
      expect(await OnboardingService.isCompleted(), isFalse);
    });

    test('markCompleted persiste el estado', () async {
      await OnboardingService.markCompleted();
      expect(await OnboardingService.isCompleted(), isTrue);
    });
  });

  group('ShareService', () {
    setUpAll(() async {
      await loadTestEnv();
    });

    test('mensajeWhatsApp incluye datos clave y enlaces', () {
      final alerta = buildSampleAlerta();
      final mensaje = ShareService.mensajeWhatsApp(alerta);

      expect(mensaje, contains('ALERTA COMUNITARIA'));
      expect(mensaje, contains('María López'));
      expect(mensaje, contains('14 años'));
      expect(mensaje, contains('Camiseta azul'));
      expect(mensaje, contains('Mercado central de Jipijapa'));
      expect(mensaje, contains('alerta-preview?id=$sampleAlertaId'));
      expect(mensaje, contains(DeepLinkService.alertaDeepLink(sampleAlertaId)));
    });

    test('mensajeWhatsApp omite último lugar si está vacío', () {
      final alerta = buildSampleAlerta(ultimaVistaTexto: '');
      final mensaje = ShareService.mensajeWhatsApp(alerta);

      expect(mensaje, isNot(contains('Último lugar visto')));
    });
  });

  group('DeepLinkService', () {
    test('alertaDeepLink genera URI válida', () {
      expect(
        DeepLinkService.alertaDeepLink(sampleAlertaId),
        'centinela://alerta?id=$sampleAlertaId',
      );
    });
  });
}
