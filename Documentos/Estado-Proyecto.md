# Estado del proyecto — Centinela

Última actualización: junio 2026 · MVP funcional en piloto Jipijapa.

---

## Resumen

| Área | Estado |
|------|--------|
| App Flutter (Android) | ✅ Flujo completo probado en campo |
| Supabase + PostGIS + FCM | ✅ Producción piloto |
| Piloto Alfa/Beta | ✅ Push, Lo vi, WhatsApp, mapa |
| Identidad visual (logo, icono, splash) | ✅ Sprint 7 |
| Sprints 8–10 (UX, backend, admin) | ✅ Código + Supabase desplegado |
| Sitio web (landing + privacidad) | ✅ https://proyecto-centinela.vercel.app |
| Play Store | ⬜ Siguiente |

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
```

APK: `build/app/outputs/flutter-apk/app-release.apk`

Instalar en Android: copiar el APK o `adb install -r build/app/outputs/flutter-apk/app-release.apk`. Si Play Protect avisa, es normal fuera de Play Store → **Instalar de todas formas**.

---

## Siguiente fase

1. Difusión comunitaria con URL pública del sitio  
2. Play Store (testing cerrado Jipijapa)  
3. Registrar sitio en Google Search Console  

---

## Referencia rápida RF (MVP)

| RF | Criterio |
|----|----------|
| RF-01 | Emitir alerta &lt; 20 s en 4G |
| RF-02 | Push en radio &lt; 10 s |
| RF-03 | Lo vi sin exponer teléfono del testigo |
| RF-04 | WhatsApp con OG y enlace web |

Checklist piloto: [Sprint-4-Checklist-Piloto.md](sprints/Sprint-4-Checklist-Piloto.md)
