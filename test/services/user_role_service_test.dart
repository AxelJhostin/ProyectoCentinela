import 'package:centinela/services/user_role_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('modo por defecto es emisor', () async {
    expect(await UserRoleService.getModo(), ModoUsuario.emisor);
    expect(await UserRoleService.puedeEmitirAlertas(), isTrue);
  });

  test('persiste modo testigo', () async {
    await UserRoleService.setModo(ModoUsuario.testigo);
    expect(await UserRoleService.getModo(), ModoUsuario.testigo);
    expect(await UserRoleService.puedeEmitirAlertas(), isFalse);
  });
}
