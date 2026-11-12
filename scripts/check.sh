#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/config/variants.sh"
source "${SCRIPT_DIR}/lib/pdf-engine.sh"

echo "Checking Resume Workbench environment..."
command -v pandoc >/dev/null 2>&1 || { echo "Missing: pandoc" >&2; exit 1; }

require_pdf_engine "${PROJECT_ROOT}" || exit 1

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
