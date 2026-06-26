/// Resultado de invocar una Edge Function de push FCM.
class PushDispatchResult {
  const PushDispatchResult({
    required this.ok,
    required this.sent,
    required this.total,
    this.message,
  });

  final bool ok;
  final int sent;
  final int total;
  final String? message;

  factory PushDispatchResult.fromResponse(dynamic data) {
    if (data is! Map) {
      return const PushDispatchResult(
        ok: false,
        sent: 0,
        total: 0,
        message: 'Respuesta inválida del servidor',
      );
    }
    final map = Map<String, dynamic>.from(data);
    return PushDispatchResult(
      ok: map['ok'] == true,
      sent: (map['sent'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
      message: map['message'] as String?,
    );
  }
}
