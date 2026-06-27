# Sprint 0 — Guía paso a paso (Centinela)

Esta guía es tu hoja de ruta. Cada paso tiene un **objetivo** (para qué sirve) y **cómo saber que quedó bien**.

---

## Fase A — Repositorio (Git + GitHub)

### Paso A1 — Commit local ✅ (hecho por el agente)

**Qué es:** Guardar una "foto" del proyecto en tu computadora con Git.

**Qué incluye:** documentación, SQL de Supabase, README, scripts.

### Paso A2 — Crear repositorio en GitHub

**Qué es:** Copia en la nube para respaldo, presentación y trabajo desde cualquier PC.

**Opción 1 — Con GitHub CLI (`gh`), si está instalado y autenticado:**

```bash
cd /Users/hernandezaxel/proyectos/ProyectoEmilia
gh repo create centinela-mvp --private --source=. --remote=origin --push
```

**Opción 2 — Manual (si no tienes `gh`):**

1. Entra a [github.com/new](https://github.com/new)
2. Nombre: `centinela-mvp` (o `proyecto-centinela`)
3. Visibilidad: **Private** (recomendado mientras desarrollas)
4. **No** marques "Add README" (ya lo tienes local)
5. Crear repositorio
6. En tu terminal:

```bash
cd /Users/hernandezaxel/proyectos/ProyectoEmilia
git remote add origin https://github.com/TU_USUARIO/centinela-mvp.git
git push -u origin main
```

**Cómo saber que quedó bien:** Ves tus archivos en github.com dentro del repo.

---

## Fase B — Supabase (proyecto NUEVO, separado de RECI)

### Paso B1 — Crear proyecto Supabase

1. [supabase.com/dashboard](https://supabase.com/dashboard) → **New project**
2. Nombre: `centinela-mvp`
3. Contraseña de BD: guárdala en un gestor de contraseñas
4. Región: la más cercana a Ecuador si aparece

**Regla:** El project ref **no** debe ser el de RECI.

### Paso B2 — Ejecutar el esquema SQL

1. En el dashboard → **SQL Editor** → New query
2. Copia todo el contenido de `supabase/migrations/20250625000000_initial_schema.sql`
3. Run

**Cómo saber que quedó bien:** En **Table Editor** ves `usuarios`, `alertas_desaparecidos`, `reacciones_avistamientos`.

### Paso B3 — Variables de entorno locales

```bash
cp .env.example .env.local
```

Edita `.env.local` con **Settings → API** de tu proyecto Centinela:

- `CENTINELA_SUPABASE_URL`
- `CENTINELA_SUPABASE_ANON_KEY`

**Nunca** pegues claves de RECI aquí.

---

## Fase C — Flutter (app móvil)

### Paso C1 — Instalar Flutter (solo una vez)

Si no tienes Flutter:

```bash
brew install --cask flutter
flutter doctor
```

Resuelve lo que `flutter doctor` marque en rojo (Android Studio / Xcode según plataforma).

### Paso C2 — Crear el proyecto Flutter dentro del repo

Desde la raíz de ProyectoEmilia:

```bash
flutter create . --org com.centinela --project-name centinela --platforms=android,ios
```

**Nota:** Si pregunta por sobrescribir archivos, revisa que no borre `README.md` ni `Documentos/`.

### Paso C3 — Estructura de carpetas (convención del proyecto)

```
lib/
├── main.dart
├── models/       # Datos (Alerta, Usuario...)
├── services/     # Supabase, FCM, ubicación
└── ui/
    ├── screens/  # Pantallas (home, emision, detalle)
    └── widgets/  # Botones, tarjetas, FAB
```

---

## Fase D — Primera conexión (Tarea 0.4)

Objetivo: la app escribe y lee **una fila de prueba** en Supabase.

1. Agregar dependencia: `supabase_flutter`
2. Inicializar con variables de `.env.local`
3. Botón temporal "Probar conexión" que inserta en `usuarios`

**Cómo saber que quedó bien:** Ves el registro nuevo en Table Editor de Supabase.

---

## Orden recomendado (como tu guía)

| # | Qué | Tiempo aprox. |
|---|-----|----------------|
| 1 | GitHub (Fase A) | 10 min |
| 2 | Supabase (Fase B) | 20 min |
| 3 | Flutter install + create (Fase C) | 30–60 min |
| 4 | Conexión SDK (Fase D) | 1–2 h |

---

## Para presentar el proyecto (tu meta)

Cuando tengas GitHub + docs + Figma + (opcional) Supabase creado, ya puedes mostrar:

- Repositorio organizado
- Documentación profesional (Charter, SDD, Sprints)
- Wireframes en Figma
- Arquitectura clara y piloto definido (Jipijapa)

Eso ya te pone **por encima** de un prototipo sin documentación.

---

## Siguiente sesión con el agente

Di: *"Sigamos Sprint 0 — ya tengo GitHub / ya creé Supabase"* y avanzamos al paso que corresponda.
