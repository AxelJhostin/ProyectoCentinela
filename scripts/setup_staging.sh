#!/usr/bin/env bash
# Configura env para proyecto Supabase staging.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cp "$ROOT/env/app.env.example" "$ROOT/env/app.env.staging"
echo "Creado env/app.env.staging"
echo "Edita con claves de centinela-staging y luego:"
echo "  cp env/app.env.staging env/app.env"
echo "Guía: Documentos/guias/Supabase-Staging.md"
