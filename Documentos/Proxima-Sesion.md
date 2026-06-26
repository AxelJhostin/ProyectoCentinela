# Próxima sesión — Centinela

## Estado

| Sprint | Estado |
|--------|--------|
| 5.1 | ✅ Fixes piloto (WhatsApp, mapa, Lo vi) |
| 5.2 | ✅ Firebase + secret Supabase configurados — **listo para probar push** |

## Probar ahora (piloto Beta push)

1. APK: `build/app/outputs/flutter-apk/app-release.apk` (~53 MB)
2. Instalar en 2+ Android (Play Protect → Instalar de todas formas si aplica)
3. Login + permisos notificaciones y GPS
4. Verificar `usuarios.fcm_token` en Supabase
5. Escenarios:
   - A emite alerta → B recibe push (≤5 km)
   - B «Lo vi» → A (emisor) recibe push

Checklists: [Sprint-5-Backlog-Fixes-Piloto.md](Sprint-5-Backlog-Fixes-Piloto.md) · [Sprint-5.2-Firebase-FCM.md](Sprint-5.2-Firebase-FCM.md)

## Después del piloto Beta

- Recoger feedback (push llegó / no llegó, batería, UX)
- Rotar service account si la clave se expuso en algún canal inseguro
