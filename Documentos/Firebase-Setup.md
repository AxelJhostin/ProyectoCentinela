# Firebase Cloud Messaging — Centinela (Sprint 5.2)

**Supabase** guarda alertas, ubicaciones y tokens; **Firebase FCM** envía la notificación nativa al celular (app cerrada). Ambos se usan juntos, no uno en lugar del otro.

Las notificaciones push requieren Firebase **separado de RECI**. La app ya invoca la Edge Function `dispatch-alert-push`; falta registrar tokens FCM en `usuarios.fcm_token`.

## 1. Crear proyecto Firebase

1. [Firebase Console](https://console.firebase.google.com/) → **Agregar proyecto** → nombre: `centinela-mvp`.
2. Agrega app **Android** con package: `com.axeljhostin.centinela`.
3. Descarga `google-services.json` → colócalo en `android/app/google-services.json`.

## 2. Gradle (Android)

En `android/settings.gradle.kts` (plugins):

```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

En `android/app/build.gradle.kts` (al final):

```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

## 3. Dependencias Flutter (cuando tengas google-services.json)

```yaml
firebase_core: ^3.12.1
firebase_messaging: ^15.2.4
```

Inicializar en `main.dart` y guardar token:

```dart
await Firebase.initializeApp();
final token = await FirebaseMessaging.instance.getToken();
if (token != null) {
  await SupabaseService.client
      .from('usuarios')
      .update({'fcm_token': token})
      .eq('auth_user_id', SupabaseService.client.auth.currentUser!.id);
}
```

## 4. Secret en Supabase

1. Firebase → Project Settings → Cloud Messaging → **Server key** (Legacy) o HTTP v1.
2. Supabase Dashboard → Project Settings → Edge Functions → **Secrets**:
   - `FCM_SERVER_KEY` = tu server key

La función `dispatch-alert-push` ya está desplegada y usa ese secret.

## 5. Probar

1. Dos dispositivos con la app, GPS activo y tokens guardados.
2. Emite una alerta desde uno → el otro debería recibir push si está dentro del radio (5 km).

## Preview WhatsApp (ya activo)

Enlace de ejemplo:

```
https://wziwufumjtpjqyuzzzyn.supabase.co/functions/v1/alerta-preview?id=<UUID_ALERTA>
```

Comparte desde **Compartir WhatsApp** en el detalle de una alerta.
