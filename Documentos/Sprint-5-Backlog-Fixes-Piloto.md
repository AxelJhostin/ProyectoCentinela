# Sprint 5 — Fixes piloto Alfa (post-prueba en campo)

Hallazgos de la prueba con 3 Android en Jipijapa y correcciones.

## Sprint 5.1 — Implementado

| Bug reportado | Solución |
|---------------|----------|
| WhatsApp no abre | `AndroidManifest` queries + intent `whatsapp://` |
| Mapa no muestra ubicación | Centrar al GPS, marcador visible, botón «Mi ubicación» |
| Solo GPS al emitir | Mapa con pin + texto «Último lugar visto» |
| «Lo vi» sin marcar dónde | Pantalla confirmar con mapa |
| Contador no actualiza al instante | Realtime en `reacciones_avistamientos` |
| Emisor sin detalle | RPC `resumen_avistamientos` (distancia, sin teléfono) |

## Sprint 5.2 — Pendiente (Firebase)

Push con app cerrada requiere **Firebase FCM** + tokens en Supabase. Ver [Firebase-Setup.md](Firebase-Setup.md).

Supabase cubre: datos, Realtime (app abierta), Edge Functions. FCM cubre: notificación nativa al celular.

## Re-prueba checklist

- [ ] Compartir WhatsApp abre la app
- [ ] Emitir con pin en universidad + texto descriptivo
- [ ] Testigo: «Lo vi» con pin en mapa
- [ ] Emisor ve contador actualizado sin salir de la pantalla
- [ ] Mapa Home centra en tu ubicación

## APK

```bash
./scripts/build_apk.sh
```
