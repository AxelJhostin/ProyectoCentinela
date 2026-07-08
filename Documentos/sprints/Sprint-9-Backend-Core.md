# Sprint 9 — Backend core + historial + offline

## Entregables

| Item | Estado |
|------|--------|
| Tabla `app_logs` + RPC `registrar_log` | Migración |
| Logs en Edge Functions | `_shared/logging.ts` |
| Rate limits (cooldown, avistamientos/hora, falsas alarmas) | Migración |
| Vista/RPC historial | `v_alertas_historial` |
| `CacheService` offline | Flutter |
| Guía staging | `Documentos/guias/Supabase-Staging.md` |

## Migraciones

- `20250708000000_sprint9_app_logs.sql`
- `20250708000001_sprint9_rate_limits.sql`
- `20250708000002_sprint9_historial.sql`

## Deploy

Aplicar migraciones en **staging** primero. Ver `Documentos/guias/Supabase-Staging.md`.
