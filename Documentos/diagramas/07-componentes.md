# Diagrama de componentes — Centinela

Arquitectura lógica por capas.

```mermaid
flowchart TB
    subgraph Cliente["Cliente móvil (Flutter)"]
        direction TB
        UI["Capa UI<br/>screens + widgets"]
        Services["Capa servicios<br/>auth, alertas, FCM, push..."]
        Models["Modelos<br/>AlertaDesaparecido, PushDispatchResult"]
        Utils["Utilidades<br/>distancia, errores, deep link parser"]
        UI --> Services
        Services --> Models
        Services --> Utils
    end

    subgraph SupabaseCloud["Supabase (centinela-mvp)"]
        Auth["Auth<br/>Anonymous Sign-In"]
        DB["PostgreSQL + PostGIS<br/>tablas, RPCs, RLS"]
        RT["Realtime<br/>postgres changes"]
        ST["Storage<br/>centinela-fotos"]
        EF["Edge Functions<br/>Deno/TypeScript"]
        Auth --> DB
        DB --> RT
        DB --> EF
        ST --> DB
    end

    subgraph Firebase["Firebase"]
        FCM["Cloud Messaging"]
    end

    subgraph Externos["Servicios externos"]
        OSM["OpenStreetMap<br/>tiles + Nominatim"]
        GMaps["Google Maps<br/>navegación externa"]
        WA["WhatsApp<br/>amplificación social"]
    end

    Services -->|"supabase_flutter"| Auth
    Services --> DB
    Services --> RT
    Services --> ST
    Services --> EF
    EF --> FCM
    FCM -->|"push"| Cliente
    UI --> OSM
    Services --> GMaps
    Services --> WA
    EF -->|"alerta-preview OG"| WA
```

---

## Responsabilidades por componente

| Componente | Responsabilidad |
|------------|-----------------|
| **UI (screens/widgets)** | Presentación, navegación, permisos |
| **Services** | Orquestación, llamadas RPC, streams Realtime |
| **Postgres RPCs** | Reglas de negocio, límites, geo-queries |
| **Edge Functions** | Push FCM, preview Open Graph |
| **RLS** | Seguridad por fila (auth.uid()) |
| **Storage** | Fotos comprimidas (&lt;280 KB para OG) |

---

## Dependencias clave (pubspec.yaml)

| Paquete | Uso |
|---------|-----|
| `supabase_flutter` | Cliente backend |
| `firebase_messaging` | Push notifications |
| `flutter_map` + `latlong2` | Mapa en app |
| `geolocator` | GPS |
| `app_links` | Deep links |
| `url_launcher` | WhatsApp, Google Maps |

[← Índice](README.md)
