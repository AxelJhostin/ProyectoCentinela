#!/usr/bin/env bash
# Crear y subir el repositorio Centinela a GitHub.
# Requisito: haber ejecutado antes `gh auth login`

set -euo pipefail

REPO_NAME="${1:-centinela-mvp}"
VISIBILITY="${2:-private}"  # private | public

cd "$(dirname "$0")/.."

if ! command -v gh >/dev/null 2>&1; then
  echo "Instala GitHub CLI: brew install gh"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Primero inicia sesión: gh auth login"
  echo "Luego vuelve a ejecutar: ./scripts/setup-github.sh"
  exit 1
fi

if git remote get-url origin >/dev/null 2>&1; then
  echo "Remote 'origin' ya existe. Subiendo cambios..."
  git push -u origin main
  exit 0
fi

gh repo create "$REPO_NAME" \
  --"$VISIBILITY" \
  --source=. \
  --remote=origin \
  --description "Proyecto Centinela — alertas comunitarias hiperlocales (MVP)" \
  --push

echo ""
echo "Listo: https://github.com/$(gh api user -q .login)/$REPO_NAME"
