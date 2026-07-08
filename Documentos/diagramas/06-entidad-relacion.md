# Diagrama entidad-relación — Centinela

Esquema de base de datos en Supabase (`centinela-mvp`) con PostGIS.

```mermaid
erDiagram
    AUTH_USERS ||--o| USUARIOS : "auth_user_id"
    USUARIOS ||--o{ ALERTAS_DESAPARECIDOS : emite
    ALERTAS_DESAPARECIDOS ||--o{ REACCIONES_AVISTAMIENTOS : recibe
    USUARIOS ||--o{ REACCIONES_AVISTAMIENTOS : reporta
    ALERTAS_DESAPARECIDOS ||--o{ REPORTES_ALERTA : es_reportada
    USUARIOS ||--o{ REPORTES_ALERTA : reporta

    AUTH_USERS {
        uuid id PK
    }

    USUARIOS {
        uuid id PK
        uuid auth_user_id UK
        text telefono_o_email
        text fcm_token
        geography ultima_ubicacion
        timestamptz ubicacion_actualizada_en
        timestamptz fecha_registro
        int score_confiabilidad
        timestamptz consentimiento_lopdp_en
    }

    ALERTAS_DESAPARECIDOS {
        uuid id PK
        uuid emisor_id FK
        text nombre_persona
        int edad_aprox
        text vestimenta
        text ultima_vista_texto
        text foto_url
        geography ubicacion_origen
        int radio_km
        enum estado
        timestamptz creado_en
    }

    REACCIONES_AVISTAMIENTOS {
        uuid id PK
        uuid alerta_id FK
        uuid testigo_id FK
        geography ubicacion_testigo
        text nota_testigo
        text ubicacion_texto
        timestamptz fecha_reporte
    }

    REPORTES_ALERTA {
        uuid id PK
        uuid alerta_id FK
        uuid reporter_id FK
        text motivo
        timestamptz creado_en
    }
```

---

## Vista y tipos

| Elemento | Descripción |
|----------|-------------|
| `estado_alerta` | ENUM: `ACTIVA`, `RESUELTA`, `FALSA_ALARMA` |
| `v_alertas_activas` | Vista con `lat`/`lng` extraídos de `ubicacion_origen` |
| `centinela-fotos` | Bucket Storage: lectura pública, escritura por `auth.uid()` |

---

## RPCs principales

| Función | Propósito |
|---------|-----------|
| `crear_alerta_desaparecido` | Crear alerta con límites de rate |
| `registrar_avistamiento` | Insertar «Lo vi» (único por testigo) |
| `resolver_alerta` | Cambiar estado a RESUELTA |
| `reportar_alerta_falsa` | Moderación comunitaria |
| `usuarios_en_radio` | Geofencing para FCM |
| `actualizar_mi_ubicacion` | Sync GPS del dispositivo |
| `actualizar_fcm_token` | Sync token push |
| `obtener_alerta` | Deep links y navegación |

---

## Índices espaciales

- `idx_usuarios_ultima_ubicacion` — GIST en `ultima_ubicacion`
- `idx_alertas_ubicacion_origen` — GIST en `ubicacion_origen`

[← Índice](README.md)
