import 'package:centinela/ui/theme/centinela_theme.dart';
import 'package:centinela/ui/widgets/alerta_card.dart';
import 'package:centinela/ui/widgets/centinela_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('AlertaCard', () {
    testWidgets('muestra nombre, distancia y tiempo de la alerta', (tester) async {
      final alerta = buildSampleAlerta();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCentinelaTheme(),
          home: Scaffold(
            body: AlertaCard(
              alerta: alerta,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('María López'), findsOneWidget);
      expect(find.textContaining('km de ti'), findsOneWidget);
      expect(find.textContaining('Alerta activa'), findsOneWidget);
    });

    testWidgets('muestra botón compartir cuando onShare está definido', (tester) async {
      var shared = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCentinelaTheme(),
          home: Scaffold(
            body: AlertaCard(
              alerta: buildSampleAlerta(),
              onTap: () {},
              onShare: () => shared = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Compartir WhatsApp'));
      expect(shared, isTrue);
    });
  });

  group('CentinelaEmptyState', () {
    testWidgets('muestra título y subtítulo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CentinelaEmptyState(
              title: 'Sin alertas activas',
              subtitle: 'Tu comunidad está tranquila',
            ),
          ),
        ),
      );

      expect(find.text('Sin alertas activas'), findsOneWidget);
      expect(find.text('Tu comunidad está tranquila'), findsOneWidget);
    });
  });

  group('buildCentinelaTheme', () {
    test('aplica colores de marca', () {
      final theme = buildCentinelaTheme();

      expect(theme.colorScheme.primary, CentinelaColors.alertCritical);
      expect(theme.scaffoldBackgroundColor, CentinelaColors.background);
    });
  });
}
