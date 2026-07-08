# Diagrama de objetos — Centinela

Instantánea del sistema durante un avistamiento «Lo vi» (escenario piloto Jipijapa).

**Contexto:** María López fue reportada como desaparecida. Carlos, un vecino a 2.4 km, presiona «Lo vi» y confirma ubicación en el mercado.

```mermaid
classDiagram
    direction LR

    object usuario_emisor {
        id = u-emisor-001
        auth_user_id = anon-aaa
        fcm_token = fcm-token-emisor
        ultima_ubicacion = POINT(-1.0036, -80.5789)
        score_confiabilidad = 100
    }

    object usuario_testigo {
        id = u-testigo-042
        auth_user_id = anon-bbb
        fcm_token = fcm-token-testigo
        ultima_ubicacion = POINT(-1.0120, -80.5700)
        score_confiabilidad = 100
    }

    object alerta_maria {
        id = a1b2-alert-789
        emisor_id = u-emisor-001
        nombre_persona = María López
        edad_aprox = 14
        vestimenta = Camiseta azul, jeans
        ultima_vista_texto = Parque central
        foto_url = storage/centinela-fotos/...
        ubicacion_origen = POINT(-1.0036, -80.5789)
        radio_km = 10
        estado = ACTIVA
    }

    object avistamiento_001 {
        id = av-001
        alerta_id = a1b2-alert-789
        testigo_id = u-testigo-042
        ubicacion_testigo = POINT(-1.0050, -80.5760)
        nota_testigo = La vi cerca del mercado
        ubicacion_texto = Mercado central, Jipijapa
        fecha_reporte = 2026-06-15T16:42:00Z
    }

    object alertaDesaparecido_ui {
        nombrePersona = María López
        distanciaKm = 2.4
        minutosReportada = 42
        distanciaTexto = A 2.4 km de ti
        tiempoTexto = Alerta activa · Hace 42 min
    }

    object avistamientoResumen_ui {
        distanciaKm = 1.8
        haceMinutos = 0
        lugarDisplay = Mercado central, Jipijapa
        lineaPrincipal = Visto cerca de: Mercado central...
    }

    object pushResult {
        ok = true
        sent = 1
        total = 1
        message = Push enviado al emisor
    }

    usuario_emisor "1" --> "emite" alerta_maria : emisor_id
    alerta_maria "1" --> "*" avistamiento_001 : alerta_id
    usuario_testigo "1" --> "reporta" avistamiento_001 : testigo_id
    alerta_maria ..> alertaDesaparecido_ui : fromMap()
    avistamiento_001 ..> avistamientoResumen_ui : fromMap()
    avistamiento_001 ..> pushResult : dispatch-avistamiento-push
```

---

## Relaciones en este escenario

| Objeto | Relación | Objeto |
|--------|----------|--------|
| `usuario_emisor` | creó | `alerta_maria` |
| `usuario_testigo` | registró | `avistamiento_001` |
| `alerta_maria` | agrupa | `avistamiento_001` |
| `alertaDesaparecido_ui` | vista en Home/Detalle | derivado de `alerta_maria` |
| `pushResult` | notifica a emisor | tras RPC + Edge Function |

---

## Restricciones activas

- Un testigo solo puede reportar **un** avistamiento por alerta (`UNIQUE alerta_id, testigo_id`).
- El teléfono del testigo **no** se expone al emisor (RF-03).
- El emisor ve `ubicacion_texto` y `nota_testigo`, no datos de contacto.

[← Índice](README.md)
