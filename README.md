# Proyecto Centinela

Plataforma móvil de **alertas comunitarias hiperlocales** para reportes de personas desaparecidas (MVP).

**Repositorio:** https://github.com/AxelJhostin/ProyectoCentinela

---

## Estado

MVP **funcional** en piloto Jipijapa (Android): emitir alerta, push en radio, Lo vi, WhatsApp, resolver caso.

**Sitio web:** https://proyecto-centinela.vercel.app (landing + privacidad + APK)

Detalle: [Documentos/Estado-Proyecto.md](Documentos/Estado-Proyecto.md)

---

## Sitio web (descarga APK)

```bash
./scripts/build_apk.sh
./scripts/prepare_web_apk.sh
cd centinela-web && npm run dev
```

Deploy gratuito: importar repo en [Vercel](https://vercel.com) con **Root Directory** = `centinela-web`. Ver [centinela-web/README.md](centinela-web/README.md).

---

## Documentación

Todo el índice en **[Documentos/README.md](Documentos/README.md)**:

- Word oficiales (requerimientos, SDD, backlog, Supabase)
- Guías (arranque, dispositivos, Firebase)
- Historial de sprints

---

## Stack

| Capa | Tecnología |
|------|------------|
| App | Flutter 3.x (Android piloto) |
| Backend | Supabase `centinela-mvp` + PostGIS |
| Push | Firebase FCM + Edge Functions |
| Amplificación | WhatsApp + Open Graph `alerta-preview` |

**Diseño:** [Figma wireframes](https://www.figma.com/design/Mq5z1DCdmuwHq7kFBVnXP8/Proyecto-Centinela-%E2%80%94-Wireframes-MVP)

---

## Inicio rápido

```bash
git clone https://github.com/AxelJhostin/ProyectoCentinela.git
cd ProyectoCentinela
./scripts/setup_env.sh
# Editar env/app.env con claves de centinela-mvp
flutter pub get
flutter run
```

Dispositivos: [Documentos/guias/Ejecutar-App-Dispositivos.md](Documentos/guias/Ejecutar-App-Dispositivos.md)

---

## APK piloto

```bash
./scripts/build_apk.sh
```

Salida: `build/app/outputs/flutter-apk/app-release.apk`

---

## Regla crítica

> **Nunca usar el Supabase de RECI.** Proyecto: `centinela-mvp` · ref `wziwufumjtpjqyuzzzyn`

---

## Estructura del repo

```
lib/              # App Flutter
supabase/         # Migraciones SQL + Edge Functions
Documentos/       # Toda la documentación (índice en README.md)
scripts/          # setup_env, build_apk, actualizar_documentos.py
env/              # Claves locales (no subir a Git)
```
