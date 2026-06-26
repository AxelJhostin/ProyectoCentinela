# Cómo ejecutar Centinela en tu Mac

## Por qué sale "No supported devices connected"

Flutter solo creó el proyecto para **Android** e **iOS**. Tu Mac detecta Chrome y macOS, pero el proyecto no los incluía al inicio.

**No es un error de tu código** — solo falta un dispositivo Android (físico o emulador), o usar Chrome para pruebas rápidas.

---

## Opción A — Chrome (rápido, ~1 min)

Sirve para probar la conexión Supabase (Sprint 0). El piloto final será Android.

```bash
cd /Users/hernandezaxel/proyectos/ProyectoEmilia
flutter run -d chrome
```

Antes: activa **Anonymous sign-in** en Supabase (Authentication → Providers → Anonymous).

---

## Opción B — Emulador Android (recomendado para desarrollo)

Ya tienes emuladores creados (`Pixel_9`, `Medium_Phone`). Hay que **encenderlos** desde Android Studio:

1. Abre **Android Studio**
2. **More Actions** → **Virtual Device Manager** (o menú **View → Tool Windows → Device Manager**)
3. Pulsa **▶ Play** en **Pixel 9**
4. Espera a que arranque el teléfono virtual (pantalla de inicio Android)
5. En la terminal:

```bash
flutter devices
```

Debes ver algo como `sdk gphone64 arm64` o `emulator-5554`.

```bash
flutter run
```

Si `flutter devices` no muestra el emulador, instala **Android SDK Command-line Tools**:

- Android Studio → **Settings** → **Languages & Frameworks** → **Android SDK** → pestaña **SDK Tools**
- Marca **Android SDK Command-line Tools (latest)** → **Apply**
- Luego en terminal:

```bash
flutter doctor --android-licenses
```

(Acepta todas con `y`)

---

## Opción C — Teléfono Android físico (mejor para el piloto real)

1. En el teléfono: **Ajustes → Acerca del teléfono** → toca **Número de compilación** 7 veces (activa opciones de desarrollador)
2. **Ajustes → Opciones de desarrollador** → activa **Depuración USB**
3. Conecta el cable USB al Mac (cable de **datos**, no solo carga)
4. En el teléfono acepta **¿Permitir depuración USB?** → **Permitir**
5. Terminal:

```bash
flutter devices
flutter run
```

---

## Comandos útiles

| Comando | Para qué |
|---------|----------|
| `flutter devices` | Ver qué dispositivos detecta |
| `flutter emulators` | Listar emuladores instalados |
| `flutter doctor` | Diagnóstico del entorno |
| `flutter run -d chrome` | Correr en navegador |
| `flutter run -d <id>` | Correr en un dispositivo específico |

---

## Qué hacer ahora (orden sugerido)

1. Prueba **Opción A** (`flutter run -d chrome`) para validar Supabase hoy.
2. Configura **Opción B** o **C** para desarrollo Android del piloto en Jipijapa.
