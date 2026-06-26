/// Mensajes legibles para errores de Supabase/Postgres.
String userFacingError(Object error) {
  final text = error.toString();

  const patterns = <String, String>{
    'Cuentas nuevas: máximo': 'Tu cuenta es nueva: puedes publicar hasta 3 alertas en 24 horas. Si ya llegaste al límite, espera un poco.',
    'Ya tienes una alerta activa': 'Ya tienes una alerta activa. Resuélvela o ciérrala antes de emitir otra.',
    'restricciones por reportes': 'Tu cuenta tiene restricciones por reportes previos.',
    'Perfil de usuario no encontrado': 'No encontramos tu perfil. Cierra la app, vuelve a iniciar sesión e intenta otra vez.',
  };

  for (final entry in patterns.entries) {
    if (text.contains(entry.key)) return entry.value;
  }

  final match = RegExp(r'message: ([^,]+), code:').firstMatch(text);
  if (match != null) {
    return match.group(1)!.trim();
  }

  return 'No se pudo completar la acción. Intenta de nuevo.';
}
