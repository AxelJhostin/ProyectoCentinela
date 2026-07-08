# Diagrama de despliegue — Centinela

Distribución física del sistema en el piloto Jipijapa.

```mermaid
flowchart TB
    subgraph Dispositivos["Dispositivos Android (piloto)"]
        AppE["App Centinela<br/>Emisor"]
        AppT["App Centinela<br/>Comunidad"]
        WAApp["WhatsApp"]
    end

    subgraph Internet["Internet"]
        CDN["OpenStreetMap<br/>tile servers"]
        Nominatim["Nominatim API<br/>geocoding"]
    end

    subgraph SupabaseCloud["Supabase Cloud (centinela-mvp)"]
        direction TB
        API["API Gateway<br/>REST + Realtime + Auth"]
        PG["PostgreSQL 15<br/>+ PostGIS"]
        StorageNode["Storage CDN<br/>centinela-fotos"]
        EdgeNode["Edge Functions<br/>Deno Deploy"]
        API --> PG
        API --> StorageNode
        API --> EdgeNode
    end

    subgraph FirebaseCloud["Firebase (centinela-mvp)"]
        FCMNode["FCM<br/>HTTP v1"]
    end

    subgraph Google["Google"]
        GMapsWeb["Google Maps<br/>app externa"]
    end

    AppE -->|"HTTPS/WSS"| API
    AppT -->|"HTTPS/WSS"| API
    AppE --> CDN
    AppT --> CDN
    AppE --> Nominatim
    AppT --> Nominatim
    EdgeNode -->|"service account"| FCMNode
    FCMNode -->|"push"| AppE
    FCMNode -->|"push"| AppT
    AppE --> WAApp
    AppT --> WAApp
    WAApp -->|"abre deep link"| AppT
    EdgeNode -->|"alerta-preview OG"| WAApp
    AppE --> GMapsWeb
    AppT --> GMapsWeb
```

---

## Artefactos de despliegue

| Artefacto | Ubicación | Cómo se despliega |
|-----------|-----------|-------------------|
| APK release | `build/app/outputs/flutter-apk/app-release.apk` | `./scripts/build_apk.sh` |
| Migraciones SQL | `supabase/migrations/` | Dashboard Supabase o `supabase db push` |
| Edge Functions | `supabase/functions/` | `supabase functions deploy` |
| Variables FCM | Secrets Supabase | `FIREBASE_SERVICE_ACCOUNT` |
| Env local | `env/app.env` | `./scripts/setup_env.sh` (no commitear) |
| Firebase config | `android/app/google-services.json` | Firebase Console (gitignored) |

---

## Entornos

| Entorno | Estado | Notas |
|---------|--------|-------|
| **Producción piloto** | Activo | Supabase `centinela-mvp`, APK sideload |
| **Local dev** | Parcial | Flutter local + Supabase remoto (sin `config.toml`) |
| **Play Store** | Planificado | Testing cerrado Jipijapa |
| **iOS / Web** | Scaffold | No es foco del piloto |

---

## Regla de aislamiento

> **Nunca desplegar en el Supabase de RECI.** Proyecto dedicado: `centinela-mvp` · ref `wziwufumjtpjqyuzzzyn`

[← Índice](README.md)
