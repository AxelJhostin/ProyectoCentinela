# Diagrama de secuencia (tiempo) — Centinela

Flujo completo: **emitir alerta → push comunitario → Lo vi → push al emisor → resolver**.

```mermaid
sequenceDiagram
    autonumber
    actor Emisor
    actor Testigo as Miembro comunidad
    participant AppE as App (Emisor)
    participant AppT as App (Testigo)
    participant Storage as Supabase Storage
    participant DB as Postgres + PostGIS
    participant EF as Edge Functions
    participant FCM as Firebase FCM

    Note over Emisor,FCM: Fase 1 — Emitir alerta (RF-01, RF-02)

    Emisor->>AppE: Completa formulario + foto + pin mapa
    AppE->>Storage: Sube foto comprimida
    Storage-->>AppE: foto_url
    AppE->>DB: RPC crear_alerta_desaparecido(...)
    DB-->>AppE: alerta_id
    AppE->>EF: invoke dispatch-alert-push
    EF->>DB: usuarios_en_radio(lat, lng, radio)
    DB-->>EF: lista fcm_tokens
    EF->>FCM: envía push a usuarios en radio
    FCM-->>AppT: 🚨 Nueva alerta cercana
    AppE->>Emisor: Compartir WhatsApp (opcional)

    Note over Testigo,FCM: Fase 2 — Reportar Lo vi (RF-03)

    Testigo->>AppT: Abre detalle desde push
    Testigo->>AppT: Presiona «Lo vi» + confirma ubicación
    AppT->>DB: RPC registrar_avistamiento(...)
    DB-->>AppT: avistamiento_id
    AppT->>EF: invoke dispatch-avistamiento-push
    EF->>FCM: push al emisor
    FCM-->>AppE: 👁 Alguien reportó un avistamiento
    AppE->>Emisor: Muestra resumen con lugar y nota

    Note over Emisor,FCM: Fase 3 — Resolver caso

    Emisor->>AppE: Marca «Resuelto»
    AppE->>DB: RPC resolver_alerta(alerta_id)
    DB-->>AppE: ok
    AppE->>EF: invoke dispatch-resuelto-push
    EF->>FCM: push a comunidad en radio
    FCM-->>AppT: ✅ Caso resuelto
```

---

## Diagrama de secuencia — Onboarding y arranque

```mermaid
sequenceDiagram
    autonumber
    actor Usuario
    participant App
    participant Prefs as SharedPreferences
    participant Auth as Supabase Auth
    participant DB as Postgres
    participant FCM as Firebase FCM

    Usuario->>App: Abre Centinela
    App->>Auth: signInAnonymously()
    Auth-->>App: session + auth_user_id
    App->>DB: upsert usuarios
    App->>Prefs: ¿onboarding completado?

    alt Primera vez
        Usuario->>App: Permisos GPS + notificaciones
        Usuario->>App: Acepta términos LOPDP
        App->>DB: RPC registrar_consentimiento_lopdp
        App->>Prefs: markCompleted()
    end

    App->>DB: RPC actualizar_mi_ubicacion
    App->>FCM: obtiene token
    App->>DB: RPC actualizar_fcm_token
    App->>Usuario: Muestra Home (mapa + alertas)
```

---

## Tiempos objetivo (SLA MVP)

| Paso | Objetivo |
|------|----------|
| Emitir alerta (4G) | &lt; 20 s (RF-01) |
| Push a radio | &lt; 10 s (RF-02) |
| Sync ubicación | cada ~3 min en Home |
| Realtime alertas | inmediato vía Postgres changes |

[← Índice](README.md)
