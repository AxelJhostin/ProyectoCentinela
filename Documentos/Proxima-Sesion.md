# Próxima sesión — Continuar en otra computadora

Última actualización: **26 jun 2025** · Commit: `8226c0e`

---

## Lo que ya está hecho (no repetir)

- [x] Documentación completa (Word + guías)
- [x] GitHub: https://github.com/AxelJhostin/ProyectoCentinela
- [x] Supabase `centinela-mvp` (proyecto **separado de RECI`)
- [x] Sprint 0 — conexión Supabase validada en emulador Mac
- [x] Sprint 1 — UI (Home, Emisión, Detalle) según Figma
- [x] Sprint 2 — código listo: onboarding, fotos, alertas reales, mapa en vivo

**Pendiente de probar bien:** flujo completo Sprint 2 (emitir alerta con foto y verla en el mapa). En la Mac el emulador fue lento; conviene probarlo en la PC grande.

---

## Setup en la computadora grande (checklist)

### 1. Clonar el repo

```bash
git clone https://github.com/AxelJhostin/ProyectoCentinela.git
cd ProyectoCentinela
```

### 2. Flutter

```bash
# Instalar Flutter si no lo tienes: https://docs.flutter.dev/get-started/install
flutter doctor
```

### 3. Variables de entorno (no van en GitHub)

```bash
./scripts/setup_env.sh
```

Edita `env/app.env` con las claves de **centinela-mvp** (copiar desde Supabase Dashboard → Settings → API):

- `CENTINELA_SUPABASE_URL`
- `CENTINELA_SUPABASE_PUBLISHABLE_KEY`

> Usa las mismas claves que ya creaste; no hace falta otro proyecto Supabase.

### 4. Dependencias

```bash
flutter pub get
```

### 5. Supabase (verificar una vez)

- Login anónimo: **Authentication → Providers → Anonymous → Enable**
- Bucket `centinela-fotos` ya debería existir (Sprint 2)

### 6. Correr la app

**Opción A — Emulador Android (recomendado en PC potente)**

```bash
# Android Studio → Device Manager → encender Pixel 9 (o similar)
flutter devices
flutter run
```

**Opción B — Teléfono físico (más rápido que emulador)**

- Depuración USB activada
- Cable conectado → `flutter run`

**Opción C — Chrome (solo pruebas rápidas, sin cámara/GPS real)**

```bash
flutter run -d chrome
```

---

## Qué probar mañana (Sprint 2 — checklist QA)

1. [ ] Onboarding: permisos GPS y notificaciones
2. [ ] Emulador/teléfono con GPS (Jipijapa: `-1.0`, `-80.5833`)
3. [ ] **EMITIR ALERTA** → foto → nombre → edad → enviar
4. [ ] Alerta aparece en mapa (pin rojo) y en bottom sheet
5. [ ] Detalle muestra foto desde Supabase Storage
6. [ ] Si eres el emisor: **Marcar como resuelto** y desaparece del mapa
7. [ ] Verificar en Supabase Table Editor: `alertas_desaparecidos` + Storage

---

## Después de probar Sprint 2 → Sprint 3

| Tarea | Descripción |
|-------|-------------|
| 3.1 | Firebase Cloud Messaging (FCM) + guardar token en `usuarios` |
| 3.2 | Edge Function: notificar usuarios en radio 5 km |
| 3.3 | Deep links + Open Graph para WhatsApp |
| 3.4 | Botón «Compartir WhatsApp» real |
| 3.5 | Botón «Lo vi» + guardar avistamiento |
| 3.6 | Ubicación en background |
| 3.7 | Post-moderación básica |

Luego **Sprint 4:** pruebas, legal, APK piloto Jipijapa.

---

## Diseño pendiente en Figma (no bloquea código)

- Onboarding visual refinado
- Vista emisor en detalle (parcialmente en app)
- Pantalla web del deep link
- Términos y condiciones / LOPDP

---

## Cómo retomar con Cursor / IA

Di algo como:

> *「Cloné el repo en mi PC grande, sigamos probando Sprint 2 / arrancamos Sprint 3」*

El README y este archivo tienen todo el contexto.
