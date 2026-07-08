# Entorno Staging — Centinela

Proyecto Supabase separado para probar migraciones Sprint 9–10 sin afectar el piloto en producción.

## Pasos

1. Crear proyecto en [Supabase Dashboard](https://supabase.com/dashboard) llamado `centinela-staging`.
2. **No** usar el proyecto `centinela-mvp` ni el de RECI para pruebas destructivas.
3. Aplicar todas las migraciones de `supabase/migrations/` en orden.
4. Desplegar Edge Functions:
   ```bash
   supabase functions deploy dispatch-alert-push
   supabase functions deploy dispatch-avistamiento-push
   supabase functions deploy dispatch-resuelto-push
   supabase functions deploy dispatch-share-push
   supabase functions deploy alerta-preview
   ```
5. Configurar secrets FCM de prueba (proyecto Firebase de desarrollo).
6. Copiar env de staging:
   ```bash
   ./scripts/setup_staging.sh
   ```
7. Editar `env/app.env` con claves del proyecto staging.
8. Verificar `CENTINELA_ENV=staging` en el archivo.

## Regla

> Migraciones nuevas: probar primero en **staging**, luego aplicar en **centinela-mvp**.

## Promover a producción

1. Revisar logs en tabla `app_logs`.
2. Ejecutar checklist piloto (Sprint 4).
3. Aplicar la misma migración en `centinela-mvp`.
