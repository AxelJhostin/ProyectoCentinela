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
| [**Sprint 5 — Fixes piloto**](Documentos/Sprint-5-Backlog-Fixes-Piloto.md) | Correcciones post-prueba Alfa |
| [**Sprint 5.2 — Firebase FCM**](Documentos/Sprint-5.2-Firebase-FCM.md) | Push comunitario y al emisor |
| [Próxima sesión](Documentos/Proxima-Sesion.md) | Estado actual y qué hacer |

## Diseño

- [Figma — Wireframes MVP](https://www.figma.com/design/Mq5z1DCdmuwHq7kFBVnXP8/Proyecto-Centinela-%E2%80%94-Wireframes-MVP)

## Stack (MVP)

| Capa | Tecnología |
|------|------------|
| App móvil | Flutter 3.x (Android piloto; Web para pruebas; iOS secundario) |
| Backend / BD | Supabase `centinela-mvp` (PostgreSQL + PostGIS) |
| Push | Firebase Cloud Messaging + Edge Functions `dispatch-alert-push`, `dispatch-avistamiento-push` |
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
| Sprint 4 — legal, QA, piloto | ✅ Prueba Alfa realizada |
| Sprint 5 — fixes piloto | ✅ 5.1 WhatsApp/mapa/Lo vi · ✅ 5.2 Firebase FCM listo para prueba |

## Sprint 5 — entregables (post-prueba Alfa)

- **WhatsApp** arreglado en Android (manifest + intent directo)
- **Mapa Home** centra en GPS, marcador visible, botón ubicación
- **Emisión** con pin en mapa + texto «Último lugar visto»
- **Lo vi** con pantalla para marcar dónde
- **Realtime** avistamientos + resumen para emisor
- **Firebase FCM (5.2):** tokens, push comunitario, push emisor en «Lo vi», tap abre alerta
- **Firebase configurado:** proyecto `centinela-mvp-ada6e`, `google-services.json` local, secret `FIREBASE_SERVICE_ACCOUNT` en Supabase

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
- Edge Functions **dispatch-alert-push** y **dispatch-avistamiento-push** (requieren `FIREBASE_SERVICE_ACCOUNT` o `FCM_SERVER_KEY`)

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
└── functions/       # alerta-preview, dispatch-alert-push, dispatch-avistamiento-push, _shared/fcm.ts
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

APK generado en:

```
build/app/outputs/flutter-apk/app-release.apk
```

Ruta absoluta en este equipo (tras el último build):

```
/Users/hernandezaxel/proyectos/ProyectoEmilia/build/app/outputs/flutter-apk/app-release.apk
```

Instalar: copiar a los celulares (Drive/WhatsApp) o `adb install -r build/app/outputs/flutter-apk/app-release.apk`. Play Protect → **Más detalles → Instalar de todas formas** si aplica.

## Probar push (piloto Beta)

1. Instalar el APK en **2+ Android** con el APK de arriba.
2. Abrir app, iniciar sesión, aceptar **notificaciones** y **ubicación**.
3. Supabase → `usuarios` → verificar `fcm_token` no nulo.
4. **A** emite alerta → **B** (≤5 km) recibe push.
5. **B** confirma «Lo vi» → **A** (emisor) recibe push.

Guía Firebase: [Firebase-Setup.md](Documentos/Firebase-Setup.md)

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
| 2025-06-29 | Sprint 5.1 — fixes piloto: WhatsApp, mapa, Lo vi con pin |
| 2025-06-26 | Sprint 5.2 — Firebase FCM + APK piloto con push |

## Piloto

- **Alfa:** Jipijapa (Android) — prueba inicial realizada
- **Beta:** Jipijapa — **prueba push FCM** (2+ dispositivos, APK Sprint 5.2)
- **Gamma:** Portoviejo (+ iOS opcional)
