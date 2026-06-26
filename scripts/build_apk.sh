#!/usr/bin/env bash
# Genera APK release para piloto Android (Sprint 4).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "→ flutter pub get"
flutter pub get

echo "→ flutter build apk --release"
flutter build apk --release

APK="build/app/outputs/flutter-apk/app-release.apk"
if [[ -f "$APK" ]]; then
  SIZE=$(du -h "$APK" | cut -f1)
  echo ""
  echo "✅ APK listo: $APK ($SIZE)"
  echo "   Instalar: adb install -r $APK"
else
  echo "❌ No se encontró el APK en $APK"
  exit 1
fi
