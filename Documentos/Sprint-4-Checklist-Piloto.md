# Sprint 4 — Checklist piloto Jipijapa (Prueba Alfa)

Objetivo: validar el MVP en condiciones reales antes del despliegue comunitario.

---

## Pre-requisitos

- [ ] APK generado: `./scripts/build_apk.sh`
- [ ] Firebase configurado ([Firebase-Setup.md](Firebase-Setup.md)) con `FCM_SERVER_KEY` en Supabase
- [ ] Consentimiento LOPDP aceptado en onboarding
- [ ] Mínimo 3 dispositivos Android con GPS activo en Jipijapa

---

## Simulacro controlado (Tarea 4.6)

| # | Escenario | Métrica objetivo | Resultado |
|---|-----------|------------------|-----------|
| 1 | Emisor completa reporte (foto + campos) | < 20 s en 4G (RF-01) | |
| 2 | Push llega a dispositivos en radio 5 km | < 10 s (RF-02) | |
| 3 | Testigo pulsa «Lo vi» | Emisor ve contador sin teléfono expuesto (RF-03) | |
| 4 | Compartir WhatsApp | OG con foto < 300 KB; enlace sin app (RF-04) | |
| 5 | Marcar resuelto | Alerta oculta en mapa; OG = Caso resuelto | |
| 6 | 3 reportes de falsa alarma | Alerta pasa a FALSA_ALARMA | |

---

## Pruebas técnicas (Tareas 4.1–4.2)

### PostGIS / radio 5 km

En Supabase SQL Editor:

```sql
SELECT * FROM usuarios_en_radio(-1.0, -80.58, 5000);
```

Anotar tiempo de respuesta: ______ ms

### Deep link + OG

1. Emitir alerta de prueba
2. Compartir por WhatsApp
3. Verificar preview con foto y nombre
4. Abrir enlace sin app instalada → página `alerta-preview`
5. Con app instalada: `adb shell am start -a android.intent.action.VIEW -d "centinela://alerta?id=UUID"`

### Compresión de fotos

- Foto original vs subida: debe ser **< 300 KB** (optimizado en `FotoService`)

---

## Legal (Tarea 4.3)

- [ ] Pantalla Términos y privacidad accesible desde onboarding
- [ ] Checkbox obligatorio antes de continuar
- [ ] `consentimiento_lopdp_en` registrado en Supabase

---

## Build (Tarea 4.5)

```bash
./scripts/build_apk.sh
# Opcional Play Store:
flutter build appbundle --release
```

APK/AAB en `build/app/outputs/`

---

## Registro de incidencias

| Fecha | Dispositivo | Problema | Severidad | Estado |
|-------|-------------|----------|-----------|--------|
| | | | | |

---

## Criterio de éxito del piloto Alfa

- ≥ 80 % de escenarios del simulacro completados sin bloqueo crítico
- Push funcional en al menos 2 dispositivos distintos
- Cero filtración de teléfonos en avistamientos
- Consentimiento LOPDP registrado en todos los participantes
