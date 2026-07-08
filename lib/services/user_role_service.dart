import 'package:shared_preferences/shared_preferences.dart';

/// Rol del usuario en el piloto: solo recibe alertas o también emite.
enum ModoUsuario {
  testigo('Recibir alertas'),
  emisor('Emitir y recibir');

  const ModoUsuario(this.etiqueta);
  final String etiqueta;
}

class UserRoleService {
  UserRoleService._();

  static const _key = 'user_modo_v1';

  static Future<ModoUsuario> getModo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    return ModoUsuario.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ModoUsuario.emisor,
    );
  }

  static Future<void> setModo(ModoUsuario modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, modo.name);
  }

  static Future<bool> puedeEmitirAlertas() async {
    return (await getModo()) == ModoUsuario.emisor;
  }
}
