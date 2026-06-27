# Sprint 7 — Identidad visual

Objetivo: que Centinela se vea y se sienta como producto de confianza comunitaria, no como prototipo.

**Estado:** planificado · **Prerequisito:** MVP funcional validado (Sprint 6 ✅)

---

## Entregables

| ID | Entregable | Criterio de aceptación |
|----|------------|------------------------|
| 7.1 | Concepto de marca | Tagline + tono (1 página) |
| 7.2 | Logo | Icono app + versión horizontal |
| 7.3 | Icono Android | Adaptive icon (foreground + background) |
| 7.4 | Splash screen | Logo al abrir la app |
| 7.5 | Onboarding | Logo real (reemplazar `Icons.shield`) |
| 7.6 | Guía de marca | Colores hex, tipografía, do/don't |
| 7.7 | Theme Flutter | `centinela_theme.dart` alineado a marca |

---

## Paleta base (refinar en Figma)

| Token | Hex actual | Uso |
|-------|------------|-----|
| Alerta | `#DC2626` | Urgencia, emitir alerta |
| Comunidad | `#2563EB` | Ayuda, Lo vi, mapa |
| WhatsApp | `#25D366` | Compartir |
| Fondo | `#F9FAFB` | Scaffold |
| Texto | `#111827` / `#6B7280` | Primario / secundario |

Tipografía: **Inter** (ya en app).

---

## Tagline (elegir una)

- *«Alertas de tu comunidad, cerca de ti.»*
- *«Cuando desaparece alguien, tu barrio responde.»*
- *«Centinela — tu comunidad alerta.»*

---

## Checklist de implementación técnica

- [ ] Assets en `assets/brand/` (logo SVG/PNG)
- [ ] `flutter_launcher_icons` en `pubspec.yaml`
- [ ] `flutter_native_splash` configurado
- [ ] Actualizar `onboarding_screen.dart` con logo
- [ ] Screenshots Play Store (post-marca)

---

## Después del Sprint 7

1. Página web mínima + política de privacidad URL  
2. Play Store (testing cerrado Jipijapa)  
3. Difusión comunitaria  

Ver [Estado-Proyecto.md](../Estado-Proyecto.md)
