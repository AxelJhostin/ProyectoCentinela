# Próxima sesión — Centinela

## Estado

| Sprint | Estado |
|--------|--------|
| 5.1 | ✅ Fixes piloto (WhatsApp, mapa, Lo vi) |
| 5.2 | ✅ Código FCM en repo · ⏳ Configurar Firebase Console + secret Supabase |

## Configurar push (una vez)

1. Firebase: proyecto `centinela-mvp`, app Android `com.axeljhostin.centinela.centinela`, descargar `google-services.json` → `android/app/`.
2. Supabase Secrets: `FIREBASE_SERVICE_ACCOUNT` (JSON service account).
3. `./scripts/build_apk.sh` e instalar en los 3 Android del piloto.

Guía completa: [Firebase-Setup.md](Firebase-Setup.md)

## Re-probar en celular

1. Generar nuevo APK: `./scripts/build_apk.sh`
2. Instalar (Play Protect → Más detalles → Instalar de todas formas)
3. Checklist: [Sprint-5-Backlog-Fixes-Piloto.md](Sprint-5-Backlog-Fixes-Piloto.md) + [Sprint-5.2-Firebase-FCM.md](Sprint-5.2-Firebase-FCM.md)

## Escenarios push

- Usuario A emite alerta → Usuario B (≤5 km) recibe push con app cerrada.
- Usuario B confirma «Lo vi» → Usuario A (emisor) recibe push.
