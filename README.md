# Proyecto Centinela

Plataforma móvil de alertas comunitarias hiperlocales para reportes de personas desaparecidas (MVP).

**Repositorio:** https://github.com/AxelJhostin/ProyectoCentinela

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Requerimientos](Documentos/ProyectoPersonalSeguridad.docx) | Project Charter, SRS, MVP, riesgos, WBS |
| [SDD](Documentos/Documento%20de%20Diseño%20del%20Sistema%20(SDD)%20-%20Proyecto%20Centinela.docx) | Flujos, esquema BD, wireframes, WhatsApp |
| [Backlog y Sprints](Documentos/Product%20Backlog%20y%20Plan%20de%20Sprints%20-%20Proyecto%20Centinela.docx) | Sprint 0–4, criterios de aceptación, DoD |
| [Guía Supabase](Documentos/Guia-Aislamiento-Supabase-Centinela.docx) | Proyecto dedicado, separado de RECI |
| [Sprint 0 — Guía](Documentos/Sprint-0-Guia-Paso-a-Paso.md) | Pasos detallados de arranque |

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
| Supabase `centinela-mvp` | ✅ Tablas + RLS + PostGIS |
| Flutter — proyecto base | ✅ |
| Sprint 0 — conexión Supabase | ✅ Validado en emulador Pixel 9 |
| Sprint 1 — UI wireframes (mock) | ✅ Home, Emisión, Detalle |
| Sprint 2 — lógica + backend | ⏳ Siguiente |
| Notificaciones / WhatsApp | ⏳ Sprint 3 |

## Estructura del código

```
lib/
├── config/          # Variables de entorno
├── models/          # Modelos de datos
├── services/        # Supabase, FCM, ubicación
├── ui/
│   ├── screens/     # Pantallas
│   ├── widgets/     # Componentes reutilizables
│   └── theme/       # Design system (colores Figma)
supabase/migrations/ # SQL versionado
env/                 # Claves locales (app.env no se sube a GitHub)
Documentos/          # Word + guías
```

## Configuración local (primera vez)

```bash
# 1. Clonar
git clone https://github.com/AxelJhostin/ProyectoCentinela.git
cd ProyectoCentinela

# 2. Variables de entorno (claves de centinela-mvp, NO RECI)
./scripts/setup_env.sh
# Editar env/app.env con tu URL y publishable key de Supabase

# 3. Supabase Auth — activar login anónimo (solo una vez)
# Dashboard → Authentication → Providers → Anonymous → Enable

# 4. Dependencias Flutter
flutter pub get
```

## Ejecutar la app

Guía completa (Chrome, emulador, teléfono): [Documentos/Ejecutar-App-Dispositivos.md](Documentos/Ejecutar-App-Dispositivos.md)

### Prueba rápida en Chrome (Sprint 0)

```bash
flutter run -d chrome
```

### Android (piloto)

```bash
# 1. Enciende emulador en Android Studio (Device Manager → Play en Pixel 9)
#    O conecta tu teléfono con depuración USB
flutter devices
flutter run
```

### Requisitos de desarrollo

- Flutter SDK (`brew install --cask flutter`)
- Android Studio o dispositivo Android para el piloto
- Xcode (opcional, para probar en iPhone)

```bash
flutter doctor
```

## Supabase — Regla crítica

> **Nunca usar el mismo proyecto Supabase que RECI.** Centinela usa `centinela-mvp` (`wziwufumjtpjqyuzzzyn`).

Migración inicial: `supabase/migrations/20250625000000_initial_schema.sql`

## Git — registrar cambios

```bash
git add .
git commit -m "Descripción clara del cambio"
git push
```

## Piloto

- **Alfa:** Jipijapa (Android)
- **Beta:** Portoviejo (+ iOS opcional)

## Próximo paso

**Sprint 2 — Lógica core:** onboarding, permisos, subida de foto a Supabase Storage, insertar alertas reales y mapa con datos en vivo.

### Hitos completados

- **2025-06-25:** Sprint 0 cerrado — app Flutter ↔ Supabase `centinela-mvp` en emulador Android.
- **2025-06-26:** Sprint 1 cerrado — 3 pantallas Figma con mock data (mapa OSM, bottom sheet, formulario, detalle).
