# Proyecto Centinela

Plataforma móvil de alertas comunitarias hiperlocales para reportes de personas desaparecidas (MVP).

**Repositorio:** https://github.com/AxelJhostin/ProyectoCentinela

---

## Cierre de sesión (26 jun 2025)

Todo el código está **commiteado y en GitHub** (`8226c0e`). Puedes pausar tranquilo.

| Hoy | Estado |
|-----|--------|
| Sprint 0 | ✅ Probado (conexión Supabase en emulador Mac) |
| Sprint 1 | ✅ UI completa (mock) |
| Sprint 2 | ✅ **Código listo** — falta probar bien en otra PC |
| Sprint 3+ | ⏳ Para otra sesión |

**Continuar en la PC grande:** lee [Documentos/Proxima-Sesion.md](Documentos/Proxima-Sesion.md) (clonar repo, `env/app.env`, `flutter run`).

---

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Requerimientos](Documentos/ProyectoPersonalSeguridad.docx) | Project Charter, SRS, MVP, riesgos, WBS |
| [SDD](Documentos/Documento%20de%20Diseño%20del%20Sistema%20(SDD)%20-%20Proyecto%20Centinela.docx) | Flujos, esquema BD, wireframes, WhatsApp |
| [Backlog y Sprints](Documentos/Product%20Backlog%20y%20Plan%20de%20Sprints%20-%20Proyecto%20Centinela.docx) | Sprint 0–4, criterios de aceptación, DoD |
| [Guía Supabase](Documentos/Guia-Aislamiento-Supabase-Centinela.docx) | Proyecto dedicado, separado de RECI |
| [Sprint 0 — Guía](Documentos/Sprint-0-Guia-Paso-a-Paso.md) | Pasos detallados de arranque |
| [**Próxima sesión**](Documentos/Proxima-Sesion.md) | **Setup en otra PC + qué probar mañana** |

## Diseño

- [Figma — Wireframes MVP](https://www.figma.com/design/Mq5z1DCdmuwHq7kFBVnXP8/Proyecto-Centinela-%E2%80%94-Wireframes-MVP)

## Stack (MVP)

| Capa | Tecnología |
|------|------------|
| App móvil | Flutter 3.x (Android piloto; Web para pruebas; iOS secundario) |
| Backend / BD | Supabase `centinela-mvp` (PostgreSQL + PostGIS) |
| Push | Firebase Cloud Messaging (Sprint 3) |
| Deep links | Vercel (Sprint 3) |

## Estado del proyecto

| Fase | Estado |
|------|--------|
| Documentación | ✅ Completa |
| GitHub | ✅ [ProyectoCentinela](https://github.com/AxelJhostin/ProyectoCentinela) |
| Supabase `centinela-mvp` | ✅ Tablas + Storage + RPCs + Realtime |
| Sprint 0 — conexión | ✅ Validado en Mac |
| Sprint 1 — UI | ✅ |
| Sprint 2 — backend en app | ✅ Código · ⏳ QA en PC grande |
| Sprint 3 — push / WhatsApp / Lo vi | ⏳ Siguiente desarrollo |
| Sprint 4 — piloto Jipijapa | ⏳ |

## Estructura del código

```
lib/
├── config/          # Variables de entorno
├── models/          # Modelos de datos
├── services/        # auth, alertas, fotos, ubicación
├── ui/
│   ├── screens/     # bootstrap, onboarding, home, emisión, detalle
│   ├── widgets/
│   └── theme/
supabase/migrations/
env/app.env          # Claves locales (NO subir a GitHub)
```

## Configuración en una PC nueva

```bash
git clone https://github.com/AxelJhostin/ProyectoCentinela.git
cd ProyectoCentinela
./scripts/setup_env.sh
# Editar env/app.env con claves de centinela-mvp
flutter pub get
flutter run
```

Detalle completo: [Documentos/Proxima-Sesion.md](Documentos/Proxima-Sesion.md)

## Ejecutar la app

Guía dispositivos: [Documentos/Ejecutar-App-Dispositivos.md](Documentos/Ejecutar-App-Dispositivos.md)

```bash
flutter devices
flutter run                    # Android emulador o teléfono
flutter run -d chrome          # Prueba rápida web (limitada)
```

## Supabase — Regla crítica

> **Nunca usar el mismo proyecto Supabase que RECI.** Proyecto: `centinela-mvp` · ref `wziwufumjtpjqyuzzzyn`

Migraciones en `supabase/migrations/` (aplicadas en la nube vía dashboard/MCP).

## Próxima sesión (orden sugerido)

1. **Probar Sprint 2** en PC grande (emitir alerta + ver en mapa) — checklist en [Proxima-Sesion.md](Documentos/Proxima-Sesion.md)
2. **Sprint 3:** FCM, geofencing push, WhatsApp deep links, botón «Lo vi»
3. **Sprint 4:** QA, legal, APK piloto Jipijapa

## Hitos

- **2025-06-25:** Sprint 0 — Flutter ↔ Supabase en emulador
- **2025-06-26:** Sprint 1 — UI wireframes
- **2025-06-26:** Sprint 2 — alertas reales, Storage, onboarding (código; QA pendiente en PC grande)

## Piloto

- **Alfa:** Jipijapa (Android)
- **Beta:** Portoviejo (+ iOS opcional)
