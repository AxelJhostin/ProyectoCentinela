# Backup y retención — Centinela

## Backups automáticos (Supabase)

1. Dashboard → Project Settings → Database → Backups.
2. Activar backups diarios en `centinela-mvp`.
3. Documentar fecha de activación en el checklist de piloto.

## Retención de datos

| Dato | Política | Mecanismo |
|------|----------|-----------|
| Alertas RESUELTA / FALSA_ALARMA | 90 días | RPC `archivar_alertas_antiguas()` |
| Historial visible en app | 30 días | Vista `v_alertas_historial` |
| Fotos en Storage | Manual / futuro cron | Revisar objetos sin alerta referenciada |

## Cron sugerido (Supabase)

Programar ejecución mensual de `archivar_alertas_antiguas` con **service role** (pg_cron o Edge Function programada).

## Recuperación

1. Restaurar backup desde Supabase Dashboard si hay incidente.
2. Re-aplicar migraciones si el restore es a instancia nueva.
3. Re-desplegar Edge Functions.

## Logs

La tabla `app_logs` puede crecer; purgar entradas > 30 días periódicamente en staging/producción.
