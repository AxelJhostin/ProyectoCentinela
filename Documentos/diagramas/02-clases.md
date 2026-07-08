# Diagrama de clases — Centinela

Modelo de dominio y capa de servicios de la app Flutter.

```mermaid
classDiagram
    direction TB

    class AlertaDesaparecido {
        +String id
        +String emisorId
        +String nombrePersona
        +int edadAprox
        +String vestimenta
        +String ultimaVistaTexto
        +double distanciaKm
        +int minutosReportada
        +double latitud
        +double longitud
        +String fotoUrl
        +int radioKm
        +DateTime creadoEn
        +String distanciaTexto
        +String tiempoTexto
        +fromMap(map, userLat, userLng)$
    }

    class UbicacionSeleccion {
        +LatLng point
        +String? etiquetaLugar
    }

    class PushDispatchResult {
        +bool ok
        +int sent
        +int total
        +String? message
        +fromResponse(data)$
    }

    class AvistamientoResumen {
        +double distanciaKm
        +int haceMinutos
        +double lat
        +double lng
        +String? notaTestigo
        +String? ubicacionTexto
        +String lugarDisplay
        +String tiempoTexto
        +String lineaPrincipal
        +fromMap(map)$
    }

    class AuthService {
        +ensureSession()$
        +authUserId$
    }

    class AlertaService {
        +fetchActivas()$
        +watchActivas()$
        +crearAlerta()$
        +resolverAlerta()$
        +fetchById()$
        +miAlertaActivaId()$
    }

    class AvistamientoService {
        +registrarLoVi()$
        +contar()$
        +resumen()$
        +watchCount()$
    }

    class PushService {
        +notificarUsuariosCercanos()$
        +notificarEmisorAvistamiento()$
        +notificarComunidadResuelto()$
    }

    class FcmService {
        +init()$
        +syncToken()$
    }

    class LocationService {
        +getCurrentPosition()$
        +syncUbicacionToSupabase()$
    }

    class ShareService {
        +mensajeWhatsApp(alerta)$
        +compartirWhatsApp(alerta)$
    }

    class DeepLinkService {
        +init(navigatorKey)$
        +alertaDeepLink(alertaId)$
    }

    class ModeracionService {
        +reportarFalsaAlarma()$
    }

    class LegalService {
        +acceptTerms()$
    }

    class SupabaseService {
        +initialize()$
        +client$
    }

    class HomeScreen
    class EmisionScreen
    class DetalleAlertaScreen
    class ConfirmarAvistamientoScreen

    AlertaService --> AlertaDesaparecido : crea/lee
    AlertaService --> SupabaseService : usa
    AvistamientoService --> AvistamientoResumen : crea
    AvistamientoService --> SupabaseService : usa
    PushService --> PushDispatchResult : retorna
    PushService --> SupabaseService : invoke functions
    ShareService --> AlertaDesaparecido : usa
    ShareService --> DeepLinkService : genera enlace
    DeepLinkService --> AlertaService : fetchById
    AuthService --> SupabaseService : usa
    LocationService --> SupabaseService : RPC ubicación
    FcmService --> SupabaseService : RPC fcm_token

    HomeScreen --> AlertaService : watchActivas
    EmisionScreen --> AlertaService : crearAlerta
    EmisionScreen --> PushService : notificar
    EmisionScreen --> ShareService : compartir
    EmisionScreen --> UbicacionSeleccion : usa
    DetalleAlertaScreen --> AvistamientoService : resumen
    DetalleAlertaScreen --> ModeracionService : reportar
    ConfirmarAvistamientoScreen --> AvistamientoService : registrarLoVi
    ConfirmarAvistamientoScreen --> UbicacionSeleccion : usa
```

---

## Notas de diseño

- **Servicios** usan patrón singleton estático (`ClassName._()`).
- **Lógica de negocio crítica** vive en RPCs Postgres (`crear_alerta_desaparecido`, `registrar_avistamiento`, etc.), no en Dart.
- **Pantallas** son clientes delgados que orquestan servicios.
- **Modelos** son inmutables con factories `fromMap` para deserializar respuestas Supabase.

[← Índice](README.md)
