# Sprint 5.2 — Firebase FCM push

## Entregables

- [x] `firebase_core` + `firebase_messaging` + `flutter_local_notifications`
- [x] `FcmService`: token → `actualizar_fcm_token`, foreground channel, tap → detalle alerta
- [x] Gradle `google-services` condicional
- [x] Edge Function `dispatch-avistamiento-push` (push al emisor)
- [x] `dispatch-alert-push` actualizado (FCM v1 + excluir emisor)
- [x] Migración `usuarios_en_radio(..., p_excluir_usuario_id)`
- [x] `PushService.notificarEmisorAvistamiento` tras «Lo vi»
- [x] Documentación [Firebase-Setup.md](Firebase-Setup.md)

## Pendiente manual (consola)

1. Crear proyecto Firebase `centinela-mvp` y descargar `google-services.json`.
2. Secret Supabase: `FIREBASE_SERVICE_ACCOUNT` (recomendado) o `FCM_SERVER_KEY`.
3. Rebuild APK e instalar en dispositivos piloto.

## Criterios de aceptación

- Push comunitario al emitir alerta (usuarios en radio, app cerrada).
- Push al emisor cuando alguien confirma «Lo vi».
- Tap abre la alerta correcta.
