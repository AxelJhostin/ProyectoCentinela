# Sprint 10 — Admin, compartidos y retención

## Entregables

| Item | Estado |
|------|--------|
| Tabla `eventos_compartir` + RPC | Migración |
| Edge Function `dispatch-share-push` | Supabase |
| Contador compartidos en Mi alerta | Flutter |
| Tabla `administradores` + RPCs admin | Migración |
| Pantalla `AdminScreen` (long-press logo) | Flutter |
| Retención 90 días | `archivar_alertas_antiguas` |
| Guía backup | `Documentos/guias/Backup-Retencion.md` |

## Migración

- `20250708000003_sprint10_share_admin_retention.sql`

## Activar un admin

En SQL Editor (producción o staging):

```sql
INSERT INTO public.administradores (auth_user_id)
VALUES ('UUID-de-auth.users-del-admin');
```

Luego en la app: mantén pulsado el logo en Home para abrir el panel.

## Deploy función nueva

```bash
supabase functions deploy dispatch-share-push
```
