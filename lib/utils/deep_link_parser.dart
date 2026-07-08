/// Parseo de URIs `centinela://alerta?id=<uuid>` para deep links.
String? parseAlertaIdFromUri(Uri uri) {
  if (uri.scheme != 'centinela') return null;
  if (uri.host != 'alerta') return null;

  final fromQuery = uri.queryParameters['id'];
  if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;

  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first.isNotEmpty) {
    return uri.pathSegments.first;
  }
  return null;
}
