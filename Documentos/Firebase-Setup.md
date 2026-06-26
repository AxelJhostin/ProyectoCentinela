# Firebase Cloud Messaging — Centinela (Sprint 5.2)

**Supabase** guarda alertas, ubicaciones y tokens FCM en `usuarios.fcm_token`. **Firebase FCM** entrega la notificación nativa (app cerrada o en segundo plano). Ambos se usan juntos.

## Flujo

1. La app obtiene token FCM → RPC `actualizar_fcm_token`.
2. Al **emitir alerta**, `PushService` invoca `dispatch-alert-push` → push a usuarios en radio (excluye emisor).
3. Al pulsar **«Lo vi»**, `PushService` invoca `dispatch-avistamiento-push` → push al emisor.
4. Tap en notificación abre `DetalleAlertaScreen` vía `alerta_id` en el payload.

## 1. Proyecto Firebase

1. [Firebase Console](https://console.firebase.google.com/) → **Agregar proyecto** → `centinela-mvp` (separado de RECI).
2. Agrega app **Android** con package: `com.axeljhostin.centinela.centinela`.
3. Descarga `google-services.json` → `android/app/google-services.json` (gitignored).
4. Plantilla de referencia: `android/app/google-services.json.example`.

**Alternativa CLI:**

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=centinela-mvp
```

## 2. Gradle (ya en repo)

- Plugin `com.google.gms.google-services` en `android/settings.gradle.kts`.
- Se aplica en `android/app/build.gradle.kts` solo si existe `google-services.json`.

## 3. Dependencias Flutter (ya en repo)

- `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
- `FcmService` en `lib/services/fcm_service.dart` — init tras login en `initSprint3Services()`.

## 4. Secret en Supabase (obligatorio para push)

Supabase Dashboard → **Project Settings → Edge Functions → Secrets** (proyecto `centinela-mvp`):

### Opción A — recomendada (FCM HTTP v1)

1. Firebase → **Project settings → Service accounts** → **Generate new private key**.
2. Secret `FIREBASE_SERVICE_ACCOUNT` = JSON completo del service account (una línea).

### Opción B — legacy

1. Firebase → Cloud Messaging → **Server key** (si aún disponible).
2. Secret `FCM_SERVER_KEY` = server key.

Las Edge Functions `dispatch-alert-push` y `dispatch-avistamiento-push` usan `_shared/fcm.ts` (v1 primero, legacy como fallback).

## 5. Migración y despliegue

```bash
# Migración (excluir emisor del radio)
supabase db push   # o aplicada vía Dashboard

# Edge Functions
supabase functions deploy dispatch-alert-push
supabase functions deploy dispatch-avistamiento-push
```

## 6. Build APK

Sin `google-services.json` la app compila pero FCM no inicializa (log: «FCM no disponible»).

```bash
./scripts/build_apk.sh
```

## 7. Probar

| Escenario | Esperado |
|-----------|----------|
| Dos Android, GPS, tokens guardados | Emisor crea alerta → receptor en ≤5 km recibe push |
| Emisor + otro usuario «Lo vi» | Emisor recibe push «Nuevo avistamiento» |
| Tap notificación | Abre detalle de la alerta |

Verificar tokens: tabla `usuarios`, columna `fcm_token` no nula tras abrir app logueada.

## Preview WhatsApp (independiente de FCM)

```
https://wziwufumjtpjqyuzzzyn.supabase.co/functions/v1/alerta-preview?id=<UUID_ALERTA>
```
