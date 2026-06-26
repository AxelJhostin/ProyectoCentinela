# Sprint 5.2 — Firebase FCM push

## Entregables

- [x] `firebase_core` + `firebase_messaging` + `flutter_local_notifications`
- [x] `FcmService`: token → `actualizar_fcm_token`, foreground channel, tap → detalle alerta
- [x] Gradle `google-services` condicional + desugaring release
- [x] Edge Function `dispatch-avistamiento-push` (push al emisor)
- [x] `dispatch-alert-push` actualizado (FCM v1 + excluir emisor)
- [x] Migración `usuarios_en_radio(..., p_excluir_usuario_id)`
- [x] `PushService.notificarEmisorAvistamiento` tras «Lo vi»
- [x] Firebase Console: proyecto `centinela-mvp-ada6e`, app Android registrada
- [x] `google-services.json` en `android/app/` (local, gitignored)
- [x] Supabase secret `FIREBASE_SERVICE_ACCOUNT`
- [x] APK release generado

## Criterios de aceptación (probar en dispositivos)

- [ ] Push comunitario al emitir alerta (usuarios en radio, app cerrada)
- [ ] Push al emisor cuando alguien confirma «Lo vi»
- [ ] Tap abre la alerta correcta

Guía: [Firebase-Setup.md](Firebase-Setup.md)
