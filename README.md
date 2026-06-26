# Proyecto Centinela

Plataforma móvil de alertas comunitarias hiperlocales para reportes de personas desaparecidas (MVP).

**Repositorio:** https://github.com/AxelJhostin/ProyectoCentinela

---

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Requerimientos](Documentos/ProyectoPersonalSeguridad.docx) | Project Charter, SRS, MVP, riesgos, WBS |
| [SDD](Documentos/Documento%20de%20Diseño%20del%20Sistema%20(SDD)%20-%20Proyecto%20Centinela.docx) | Flujos, esquema BD, wireframes, WhatsApp |
| [Backlog y Sprints](Documentos/Product%20Backlog%20y%20Plan%20de%20Sprints%20-%20Proyecto%20Centinela.docx) | Sprint 0–4, criterios de aceptación, DoD |
| [Guía Supabase](Documentos/Guia-Aislamiento-Supabase-Centinela.docx) | Proyecto dedicado, separado de RECI |
| [Sprint 0 — Guía](Documentos/Sprint-0-Guia-Paso-a-Paso.md) | Pasos detallados de arranque |
| [Firebase FCM](Documentos/Firebase-Setup.md) | Configurar push notifications |
| [Piloto Jipijapa](Documentos/Sprint-4-Checklist-Piloto.md) | Checklist y métricas Sprint 4 |
| [Próxima sesión](Documentos/Proxima-Sesion.md) | Estado actual y qué hacer |

## Diseño

- [Figma — Wireframes MVP](https://www.figma.com/design/Mq5z1DCdmuwHq7kFBVnXP8/Proyecto-Centinela-%E2%80%94-Wireframes-MVP)

## Stack (MVP)

| Capa | Tecnología |
|------|------------|
| App móvil | Flutter 3.x (Android piloto; Web para pruebas; iOS secundario) |
| Backend / BD | Supabase `centinela-mvp` (PostgreSQL + PostGIS) |
| Push | Firebase Cloud Messaging + Edge Function `dispatch-alert-push` |
| Deep links / OG | `centinela://alerta` + Edge Function `alerta-preview` |

## Estado del proyecto

| Fase | Estado |
|------|--------|
| Documentación | ✅ Completa |
| GitHub | ✅ [ProyectoCentinela](https://github.com/AxelJhostin/ProyectoCentinela) |
| Supabase `centinela-mvp` | ✅ Tablas + Storage + RPCs + Realtime + Edge Functions |
| Sprint 0 — conexión | ✅ |
| Sprint 1 — UI wireframes | ✅ |
| Sprint 2 — backend en app | ✅ |
| Sprint 3 — geofencing y amplificación | ✅ |
| Sprint 4 — legal, QA, piloto | ✅ Código listo · ⏳ Prueba Alfa Jipijapa |

## Sprint 4 — entregables

- **Términos y LOPDP** en onboarding (checkbox obligatorio + pantalla legal)
- **Notificación al emisor** cuando alguien pulsa «Lo vi» (sin exponer teléfono)
- **Compresión de fotos** objetivo < 300 KB (preview WhatsApp)
- **Script APK** `./scripts/build_apk.sh`
- **Checklist piloto** [Sprint-4-Checklist-Piloto.md](Documentos/Sprint-4-Checklist-Piloto.md)

## Sprint 3 — entregables

- Botón **¡Lo vi!** con RPC `registrar_avistamiento`
- **Compartir WhatsApp** con preview Open Graph (`alerta-preview`)
- **Deep links** `centinela://alerta?id=…`
- **Post-moderación**: reportar falsa, límites cuentas nuevas, `score_confiabilidad`
- Sync de ubicación cada 3 min + al volver a la app
- Edge Function **dispatch-alert-push** (requiere `FCM_SERVER_KEY`)

## Estructura del código

```
lib/
├── config/
├── models/
├── services/        # auth, alertas, avistamientos, fotos, push, share, deep links, legal…
├── ui/screens/
├── ui/widgets/
└── ui/theme/
supabase/
├── migrations/
└── functions/       # alerta-preview, dispatch-alert-push
env/app.env          # Claves locales (NO subir a GitHub)
```

## Configuración rápida

```bash
git clone https://github.com/AxelJhostin/ProyectoCentinela.git
cd ProyectoCentinela
./scripts/setup_env.sh
# Editar env/app.env con claves de centinela-mvp
flutter pub get
flutter run
```

Guía dispositivos: [Documentos/Ejecutar-App-Dispositivos.md](Documentos/Ejecutar-App-Dispositivos.md)

## Build APK (piloto)

```bash
./scripts/build_apk.sh
```

APK en `build/app/outputs/flutter-apk/app-release.apk`

## Supabase — Regla crítica

> **Nunca usar el mismo proyecto Supabase que RECI.** Proyecto: `centinela-mvp` · ref `wziwufumjtpjqyuzzzyn`

## Hitos

| Fecha | Hito |
|-------|------|
| 2025-06-25 | Sprint 0 — Flutter ↔ Supabase |
| 2025-06-26 | Sprint 1 — UI wireframes |
| 2025-06-26 | Sprint 2 — alertas reales, Storage, onboarding |
| 2025-06-27 | Sprint 3 — Lo vi, WhatsApp, deep links, moderación |
| 2025-06-28 | Sprint 4 — legal LOPDP, avistamientos emisor, build APK |

## Piloto

- **Alfa:** Jipijapa (Android)
- **Beta:** Portoviejo (+ iOS opcional)
