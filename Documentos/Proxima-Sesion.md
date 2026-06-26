# Próxima sesión — Centinela

## Estado Sprint 3

| Tarea | Estado |
|-------|--------|
| 3.1 FCM token | ⏳ Stub listo — falta Firebase (`Documentos/Firebase-Setup.md`) |
| 3.2 Push geofencing | ✅ Edge Function `dispatch-alert-push` |
| 3.3 Deep links + OG | ✅ `centinela://alerta?id=…` + `alerta-preview` |
| 3.4 WhatsApp | ✅ |
| 3.5 Lo vi + Resolver | ✅ |
| 3.6 Ubicación periódica | ✅ Timer 3 min + al volver a la app |
| 3.7 Post-moderación | ✅ Reportar falsa + límites cuentas nuevas |

## Probar (emulador o teléfono, cuando quieras)

```bash
flutter pub get
flutter run
```

1. Detalle → **Compartir WhatsApp** (mensaje + enlace preview).
2. Detalle → **¡Lo Vi!** con GPS.
3. Detalle → icono **bandera** → reportar alerta falsa.
4. Deep link (terminal): `adb shell am start -a android.intent.action.VIEW -d "centinela://alerta?id=UUID_ALERTA"`

## Siguiente: Sprint 4

- Configurar Firebase para push real
- QA legal + piloto Jipijapa
- Pruebas con celulares físicos
