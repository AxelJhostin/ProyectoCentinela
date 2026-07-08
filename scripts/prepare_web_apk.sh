#!/usr/bin/env bash
# Copia el APK release al sitio Astro para despliegue en Vercel.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
DEST="$ROOT/centinela-web/public/centinela.apk"

if [[ ! -f "$SRC" ]]; then
  echo "❌ No existe $SRC"
  echo "   Ejecuta primero: ./scripts/build_apk.sh"
  exit 1
fi

cp "$SRC" "$DEST"
SIZE=$(du -h "$DEST" | cut -f1)
echo "✅ APK copiado a centinela-web/public/centinela.apk ($SIZE)"
