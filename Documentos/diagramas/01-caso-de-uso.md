# Diagrama de casos de uso — Centinela

Actores y funcionalidades del MVP.

```mermaid
flowchart TB
    subgraph Actores
        Emisor((Emisor))
        Comunidad((Miembro<br/>comunidad))
        Sistema((Sistema<br/>Centinela))
    end

    subgraph Onboarding["Onboarding y legal"]
        UC1([Completar onboarding])
        UC2([Aceptar términos LOPDP])
        UC3([Otorgar permisos GPS y notificaciones])
    end

    subgraph Alertas["Gestión de alertas"]
        UC4([Emitir alerta de desaparecido])
        UC5([Ver alertas activas en mapa])
        UC6([Ver detalle de alerta])
        UC7([Resolver alerta])
        UC8([Reportar alerta falsa])
    end

    subgraph ComunidadUC["Participación comunitaria"]
        UC9([Reportar Lo vi])
        UC10([Compartir por WhatsApp])
        UC11([Abrir alerta desde deep link])
        UC12([Abrir ubicación en Google Maps])
    end

    subgraph Notificaciones["Notificaciones"]
        UC13([Recibir push de nueva alerta])
        UC14([Recibir push de avistamiento])
        UC15([Recibir push de caso resuelto])
    end

    Emisor --> UC1
    Emisor --> UC2
    Emisor --> UC3
    Emisor --> UC4
    Emisor --> UC5
    Emisor --> UC6
    Emisor --> UC7
    Emisor --> UC10
    Emisor --> UC12
    Emisor --> UC14

    Comunidad --> UC1
    Comunidad --> UC2
    Comunidad --> UC3
    Comunidad --> UC5
    Comunidad --> UC6
    Comunidad --> UC8
    Comunidad --> UC9
    Comunidad --> UC10
    Comunidad --> UC11
    Comunidad --> UC12
    Comunidad --> UC13
    Comunidad --> UC14
    Comunidad --> UC15

    Sistema --> UC4
    Sistema --> UC9
    Sistema --> UC13
    Sistema --> UC14
    Sistema --> UC15
    Sistema --> UC8

    UC4 -.include.-> UC3
    UC9 -.include.-> UC3
    UC10 -.include.-> UC6
    UC11 -.extend.-> UC6
```

---

## Descripción de casos de uso

| ID | Caso de uso | Actor | Descripción |
|----|-------------|-------|-------------|
| UC-01 | Emitir alerta | Emisor | Sube foto, datos y ubicación; notifica usuarios en radio |
| UC-02 | Ver alertas activas | Ambos | Mapa + lista ordenada por distancia en tiempo real |
| UC-03 | Reportar Lo vi | Comunidad | Marca ubicación y nota; notifica al emisor sin exponer teléfono |
| UC-04 | Compartir WhatsApp | Ambos | Mensaje con Open Graph y deep link `centinela://` |
| UC-05 | Resolver alerta | Emisor | Cierra el caso y notifica a la comunidad en radio |
| UC-06 | Reportar falsa alarma | Comunidad | 3+ reportes marcan la alerta como `FALSA_ALARMA` |
| UC-07 | Recibir push | Comunidad/Emisor | FCM según evento: nueva alerta, avistamiento o resuelto |

---

## Requisitos funcionales vinculados

| RF | Casos de uso |
|----|--------------|
| RF-01 Emitir &lt; 20 s | UC-04 |
| RF-02 Push &lt; 10 s | UC-13, UC-14, UC-15 |
| RF-03 Lo vi sin teléfono | UC-09 |
| RF-04 WhatsApp con OG | UC-10 |

[← Índice](README.md)
