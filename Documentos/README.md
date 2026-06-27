# Documentación — Proyecto Centinela

Índice único de toda la documentación del repositorio.

---

## Estado actual

| Documento | Uso |
|-----------|-----|
| [**Estado del proyecto**](Estado-Proyecto.md) | Qué está hecho, qué sigue |

---

## Documentos oficiales (Word)

Archivos formales del proyecto — no mover de esta carpeta.

| Archivo | Contenido |
|---------|-----------|
| [ProyectoPersonalSeguridad.docx](ProyectoPersonalSeguridad.docx) | Requerimientos, charter, SRS, MVP, riesgos |
| [Documento de Diseño del Sistema (SDD) - Proyecto Centinela.docx](Documento%20de%20Dise%C3%B1o%20del%20Sistema%20(SDD)%20-%20Proyecto%20Centinela.docx) | Flujos, BD, wireframes, WhatsApp |
| [Product Backlog y Plan de Sprints - Proyecto Centinela.docx](Product%20Backlog%20y%20Plan%20de%20Sprints%20-%20Proyecto%20Centinela.docx) | Backlog, sprints, criterios de aceptación |
| [Guia-Aislamiento-Supabase-Centinela.docx](Guia-Aislamiento-Supabase-Centinela.docx) | Proyecto Supabase dedicado (separado de RECI) |

Actualizar Word desde código cuando cambie el alcance:

```bash
python3 scripts/actualizar_documentos.py
```

---

## Guías operativas

| Guía | Para qué |
|------|----------|
| [Sprint 0 — Arranque](guias/Sprint-0-Guia-Paso-a-Paso.md) | Primer setup Git, Supabase, Flutter |
| [Ejecutar en dispositivos](guias/Ejecutar-App-Dispositivos.md) | Android físico, emulador, web |
| [Firebase FCM](guias/Firebase-Setup.md) | Push notifications, secrets, deploy functions |
| [Guía de marca](guias/Guia-Marca-Centinela.md) | Logo, colores, tagline, assets |

---

## Historial de sprints (Markdown)

| Sprint | Documento |
|--------|-------------|
| 4 | [Checklist piloto Jipijapa](sprints/Sprint-4-Checklist-Piloto.md) |
| 5 | [Fixes piloto + FCM](sprints/Sprint-5-Piloto-Fixes-FCM.md) |
| 6 | [Cierre de ciclo](sprints/Sprint-6-Cierre-Ciclo.md) |
| 7 | [Identidad visual](sprints/Sprint-7-Identidad-Visual.md) |

---

## Diseño

- [Figma — Wireframes MVP](https://www.figma.com/design/Mq5z1DCdmuwHq7kFBVnXP8/Proyecto-Centinela-%E2%80%94-Wireframes-MVP)

---

## Regla crítica

> **Nunca usar el proyecto Supabase de RECI.** Proyecto Centinela: `centinela-mvp` · ref `wziwufumjtpjqyuzzzyn`
