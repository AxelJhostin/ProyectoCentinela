# Sprint 5 — Fixes piloto + Firebase FCM

Post-prueba Alfa en Jipijapa (3 Android). Incluye 5.1, 5.2 y 5.3.

---

## 5.1 — Fixes en app

| Bug | Solución |
|-----|----------|
| WhatsApp no abre | `AndroidManifest` queries + intent `whatsapp://` |
| Mapa Home | Centrar GPS, marcador, botón «Mi ubicación» |
| Emisión | Pin en mapa + «Último lugar visto» |
| Lo vi | Pantalla confirmar con mapa |
| Contador avistamientos | Realtime en `reacciones_avistamientos` |
| Detalle emisor | RPC `resumen_avistamientos` (sin teléfono) |

## 5.2 — Firebase FCM

- Tokens en `usuarios.fcm_token` · Edge Functions push  
- Proyecto Firebase `centinela-mvp-ada6e`  
- Secret `FIREBASE_SERVICE_ACCOUNT` en Supabase  
- Guía: [Firebase-Setup.md](../guias/Firebase-Setup.md)

## 5.3 — Avistamientos enriquecidos

- Nota y lugar del testigo  
- Push al emisor con más detalle  
- Radio push piloto ampliado a 10 km (luego configurable en Sprint 6)

---

## Checklist (validado en piloto Beta)

- [x] WhatsApp abre  
- [x] Emitir con pin + texto  
- [x] Lo vi con mapa  
- [x] Push comunitario (app cerrada)  
- [x] Push al emisor en Lo vi  
