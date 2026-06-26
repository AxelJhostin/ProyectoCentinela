# Próxima sesión — Centinela

## Estado actual

| Sprint | Estado |
|--------|--------|
| 0–3 | ✅ Código en GitHub |
| 4 | ✅ Legal, avistamientos emisor, APK script · ⏳ Piloto Jipijapa |

## Antes del piloto

1. Configurar **Firebase** → [Firebase-Setup.md](Firebase-Setup.md)
2. Generar APK: `./scripts/build_apk.sh`
3. Seguir checklist → [Sprint-4-Checklist-Piloto.md](Sprint-4-Checklist-Piloto.md)

## Comandos

```bash
git pull
flutter pub get
flutter run              # desarrollo
./scripts/build_apk.sh   # APK piloto
```

## Pendiente post-Sprint 4

- Prueba Alfa en Jipijapa con 3+ dispositivos
- Revisión legal del texto LOPDP por abogado
- Firebase FCM para push real en campo
