# Sprint 6 — Cierre de ciclo y experiencia testigo

Post-piloto Beta: feedback al emisor, push más útiles, radio configurable y UX testigo.

## Épica A — Emisor y push

| ID | Entregable | Estado |
|----|------------|--------|
| A1 | Diálogo «Se notificó a N personas» tras emitir | ✅ |
| A2 | Push comunitario con edad + último lugar + radio | ✅ |
| A3 | Push «Lo vi» con lugar, distancia y nota | ✅ |
| A4 | Push «Caso resuelto» a testigos y usuarios en radio | ✅ |

## Épica B — Radio configurable

| ID | Entregable | Estado |
|----|------------|--------|
| B1 | Selector 10 / 30 / 50 km en emisión (default 10, máx. BD 50) | ✅ |

## Épica C — Experiencia testigo

| ID | Entregable | Estado |
|----|------------|--------|
| C1 | Guía única «¿Cómo puedes ayudar?» al entrar a Home | ✅ |
| C2 | Pines de alerta tocables en mapa Home | ✅ |
| C3 | Botón compartir WhatsApp en tarjetas del panel Home | ✅ |

## Edge Functions

| Función | Cambio |
|---------|--------|
| `dispatch-alert-push` | Cuerpo enriquecido + `edad_aprox`, `ultima_vista_texto` |
| `dispatch-avistamiento-push` | Lugar, distancia, nota en el push |
| `dispatch-resuelto-push` | **Nueva** — notifica testigos + radio al resolver |

Desplegar en Supabase:

```bash
supabase functions deploy dispatch-alert-push
supabase functions deploy dispatch-avistamiento-push
supabase functions deploy dispatch-resuelto-push
```

## Checklist re-prueba

- [ ] Emitir con radio 30 o 50 km → mensaje con N correcto
- [ ] Emitir con nadie cerca → sugerencia WhatsApp + botón difundir
- [ ] B recibe push con edad y lugar
- [ ] B «Lo vi» con nota → A recibe push con detalle
- [ ] A resuelve → B recibe «Caso resuelto»
- [ ] Primera vez en Home: guía testigo
- [ ] Tap en pin del mapa abre detalle
- [ ] Compartir desde tarjeta en Home abre WhatsApp

## APK

```bash
./scripts/build_apk.sh
```
