# Próxima sesión — Centinela

## Estado

| Sprint | Estado |
|--------|--------|
| 5.1–5.3 | ✅ Piloto Beta (push, avistamientos, mapa) |
| 6 | ✅ Código + **Edge Functions desplegadas** en Supabase |

## Desplegado en Supabase (26 jun 2026)

- `dispatch-alert-push` v5 — push enriquecido (edad, lugar, radio)
- `dispatch-avistamiento-push` v3 — lugar, distancia, nota
- `dispatch-resuelto-push` v2 — **nueva** — aviso al resolver

## Probar ahora

1. `./scripts/build_apk.sh`
2. Instalar APK en 2+ Android con GPS y notificaciones
3. Escenarios [Sprint-6-Backlog.md](Sprint-6-Backlog.md):
   - Emitir con radio 10 km → ver «Se notificó a N personas»
   - Emitir lejos de otros usuarios → botón WhatsApp
   - «Lo vi» con nota → push al emisor con lugar
   - Marcar resuelto → push «Caso resuelto» a testigos
   - Guía testigo (primera vez) + pin tocable + share en Home

## Después

- Play Store / firma release (cuando decidas escalar)
- iOS + APNs (secundario)
