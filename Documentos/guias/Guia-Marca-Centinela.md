# Guía de marca — Centinela (Sprint 7)

## Propósito

Alertas comunitarias hiperlocales para personas desaparecidas. Tono: **serio, humano, local, confiable**.

## Tagline oficial

**Alertas de tu comunidad, cerca de ti.**

## Logo e icono

| Asset | Uso |
|-------|-----|
| `assets/brand/app_icon.png` | Launcher, onboarding (recorte) |
| `assets/brand/app_icon_foreground.png` | Adaptive icon Android (foreground) |
| `assets/brand/splash_logo.png` | Splash nativo al abrir la app |

**Concepto:** ojo comunitario + pin de mapa · azul dominante · acento rojo mínimo en la punta del pin.

## Colores

| Token | Hex | Uso |
|-------|-----|-----|
| Comunidad | `#2563EB` | Marca, Lo vi, foco, fondo adaptive icon |
| Alerta | `#DC2626` | Emitir alerta, urgencia (botones) |
| WhatsApp | `#25D366` | Solo acción compartir |
| Fondo | `#F9FAFB` | Splash, scaffold |
| Texto primario | `#111827` | Títulos |
| Texto secundario | `#6B7280` | Subtítulos |

## Tipografía

**Inter** (Google Fonts) — ya en `centinela_theme.dart`.

## Do / Don't

| ✅ Sí | ❌ No |
|------|------|
| Azul como color de marca | Escudos militares, sirenas |
| Rojo solo para acciones críticas | Sensacionalismo en textos |
| Icono simple a 48px | Texto dentro del icono launcher |
| Tagline en onboarding y materiales | Mezclar verde WhatsApp en el logo |

## Regenerar iconos / splash

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Widget Flutter

`CentinelaLogo` en `lib/ui/widgets/centinela_logo.dart` — logo + nombre + tagline.
