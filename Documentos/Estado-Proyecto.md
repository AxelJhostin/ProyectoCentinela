# Estado del proyecto — Centinela

Última actualización: julio 2026 · MVP funcional en piloto Manabí.

---

## Resumen

| Área | Estado |
|------|--------|
| App Flutter (Android) | ✅ Flujo completo probado en campo |
| Supabase + PostGIS + FCM | ✅ Producción piloto |
| Piloto Alfa/Beta | ✅ Push, Lo vi, WhatsApp, mapa |
| Identidad visual (logo, icono, splash) | ✅ Sprint 7 |
| Sprints 8–10 (UX, backend, admin) | ✅ Código + Supabase desplegado |
| Sprint 12 (UX app, APK web) | ✅ v0.1.1 — modo testigo/emisor, Acerca, pull-to-refresh |
| Sitio web (landing + privacidad) | ✅ https://proyecto-centinela.vercel.app |
| Play Store | ⬜ Pospuesto — pruebas vía APK en sitio |

---

## Sprints completados

| Sprint | Entregable clave |
|--------|------------------|
| 0–2 | Conexión Supabase, UI, alertas reales |
| 3 | Lo vi, WhatsApp OG, deep links, moderación |
| 4 | LOPDP, APK, checklist piloto |
| 5 | Fixes Alfa, FCM, avistamientos enriquecidos |
| 6 | Radio 10/30/50 km, feedback emisor, push resuelto, Google Maps en avistamientos |
| 7 | Logo, icono adaptive, splash, onboarding, guía de marca |
| 8 | Mi alerta activa, filtros, validación foto, onboarding contextual |
| 9 | Logs, rate limits, historial, offline, staging |
| 10 | Compartidos + push, panel admin, retención 90 días |
| 12 | Modo testigo/emisor, pantalla Acerca, tips contextuales, errores amigables, APK 0.1.1 en web |

Detalle: [sprints/](sprints/) · Marca: [Guia-Marca-Centinela.md](guias/Guia-Marca-Centinela.md)

---

## Backend desplegado (Supabase)

| Edge Function | Versión aprox. | Rol |
|---------------|----------------|-----|
| `dispatch-alert-push` | v5 | Push comunitario en radio |
| `dispatch-avistamiento-push` | v3 | Push al emisor con lugar/nota |
| `dispatch-resuelto-push` | v2 | Aviso al marcar resuelto |
| `alerta-preview` | v2 | Open Graph WhatsApp |

---

## Build e instalación

```bash
./scripts/build_apk.sh
./scripts/prepare_web_apk.sh   # copia APK a centinela-web/public/
```

APK: `build/app/outputs/flutter-apk/app-release.apk` · Web: `/centinela.apk` (v0.1.1)

Instalar en Android: copiar el APK o `adb install -r build/app/outputs/flutter-apk/app-release.apk`. Si Play Protect avisa, es normal fuera de Play Store → **Instalar de todas formas**.

---

## Siguiente fase

1. Probar v0.1.1 en campo (descargar APK desde el sitio)
2. Difusión comunitaria con URL pública del sitio  
3. Play Store (cuando el piloto lo requiera)  
4. Registrar sitio en Google Search Console  

---

## Referencia rápida RF (MVP)

| RF | Criterio |
|----|----------|
| RF-01 | Emitir alerta &lt; 20 s en 4G |
| RF-02 | Push en radio &lt; 10 s |
| RF-03 | Lo vi sin exponer teléfono del testigo |
| RF-04 | WhatsApp con OG y enlace web |

Checklist piloto: [Sprint-4-Checklist-Piloto.md](sprints/Sprint-4-Checklist-Piloto.md)
