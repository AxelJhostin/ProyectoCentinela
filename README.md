# Proyecto Centinela

Plataforma móvil de alertas comunitarias hiperlocales para reportes de personas desaparecidas (MVP).

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Requerimientos](Documentos/ProyectoPersonalSeguridad.docx) | Project Charter, SRS, MVP, riesgos, WBS |
| [SDD](Documentos/Documento%20de%20Diseño%20del%20Sistema%20(SDD)%20-%20Proyecto%20Centinela.docx) | Flujos, esquema BD, wireframes, WhatsApp |
| [Backlog y Sprints](Documentos/Product%20Backlog%20y%20Plan%20de%20Sprints%20-%20Proyecto%20Centinela.docx) | Sprint 0–4, criterios de aceptación, DoD |
| [Guía Supabase](Documentos/Guia-Aislamiento-Supabase-Centinela.docx) | Proyecto dedicado, separado de RECI |

## Diseño

- [Figma — Wireframes MVP](https://www.figma.com/design/Mq5z1DCdmuwHq7kFBVnXP8/Proyecto-Centinela-%E2%80%94-Wireframes-MVP)

## Stack (MVP)

- **App móvil:** Flutter (Android piloto; iOS validación secundaria)
- **Backend / BD:** Supabase (PostgreSQL + PostGIS) — **proyecto dedicado `centinela-mvp`**
- **Push:** Firebase Cloud Messaging (FCM)
- **Deep links web:** Vercel (página pública con Open Graph)

## Supabase — Regla crítica

> **Nunca usar el mismo proyecto Supabase que RECI.** Centinela tiene su propia instancia, claves y migraciones.

Variables de entorno (ejemplo):

```env
CENTINELA_SUPABASE_URL=https://xxxxx.supabase.co
CENTINELA_SUPABASE_ANON_KEY=eyJ...
```

El esquema SQL inicial está en `supabase/migrations/`.

## Estado actual

| Fase | Estado |
|------|--------|
| Requerimientos | Documentado |
| Arquitectura / SDD | Documentado |
| Diseño UI (Figma) | 3 pantallas core + design system |
| Implementación | Pendiente (Sprint 0) |
| Supabase | Sin crear aún |

## Próximo paso

**Sprint 0:** crear repo Flutter, proyecto Supabase `centinela-mvp`, ejecutar migración SQL, conectar SDK.

## Piloto

- **Alfa:** Jipijapa (Android)
- **Beta:** Portoviejo (escala + posible iOS TestFlight)
