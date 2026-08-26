#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/config/variants.sh"
PDF_ENGINE="${PDF_ENGINE:-weasyprint}"

echo "Checking Resume Workbench environment..."
command -v pandoc >/dev/null 2>&1 || { echo "Missing: pandoc" >&2; exit 1; }

if ! command -v "${PDF_ENGINE}" >/dev/null 2>&1 \
  && [ ! -x "${PROJECT_ROOT}/.venv/bin/weasyprint" ]; then
  echo "Missing: ${PDF_ENGINE} (PATH or .venv/bin/weasyprint)" >&2
  exit 1
fi

for variant in "${RESUME_VARIANTS[@]}"; do
  resolve_variant "${variant}"
  [ -f "${PROJECT_ROOT}/resume/${SOURCE_FILE}" ] \
    || { echo "Missing: resume/${SOURCE_FILE}" >&2; exit 1; }
done

for path in \
  styles/base-common.css styles/base.css styles/base-en.css \
  styles/base-wenkai.css styles/theme-conservative.css styles/theme-english.css; do
  [ -f "${PROJECT_ROOT}/${path}" ] || { echo "Missing: ${path}" >&2; exit 1; }
done

echo "Resume Workbench environment looks good."
