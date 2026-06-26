#!/usr/bin/env bash
# Copia plantillas de entorno para desarrollo local.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -f "$ROOT/env/app.env" ]]; then
  cp "$ROOT/env/app.env.example" "$ROOT/env/app.env"
  echo "Creado env/app.env — edítalo con tus claves de centinela-mvp."
else
  echo "env/app.env ya existe."
fi

if [[ ! -f "$ROOT/.env.local" ]]; then
  cp "$ROOT/.env.example" "$ROOT/.env.local"
  echo "Creado .env.local — opcional para scripts fuera de Flutter."
fi
