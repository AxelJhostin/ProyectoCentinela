# Sprint 6 — Cierre de ciclo y experiencia testigo

Post-piloto Beta: feedback al emisor, radio configurable, UX testigo y Google Maps.

## Entregables

| Área | Item | Estado |
|------|------|--------|
| Emisor | Diálogo «Se notificó a N personas» | ✅ |
| Emisor | Push enriquecido (edad, lugar, radio) | ✅ |
| Emisor | Push Lo vi con lugar, distancia, nota | ✅ |
| Comunidad | Push «Caso resuelto» | ✅ |
| Emisión | Radio 10 / 30 / 50 km | ✅ |
| Testigo | Guía única al entrar a Home | ✅ |
| Testigo | Pines tocables + WhatsApp en Home | ✅ |
| Búsqueda | Abrir avistamiento en Google Maps | ✅ |

## Edge Functions (desplegadas en Supabase)

- `dispatch-alert-push` v5  
- `dispatch-avistamiento-push` v3  
- `dispatch-resuelto-push` v2  

Guía deploy: [Firebase-Setup.md](../guias/Firebase-Setup.md)

## Validación en campo (jun 2026)

Flujo completo probado en piloto Jipijapa — emitir, push, Lo vi, detalle emisor, resolver, WhatsApp.

## Build

```bash
./scripts/build_apk.sh
```
