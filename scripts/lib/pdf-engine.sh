#!/bin/bash

# Resolve PDF_ENGINE: use the override (default weasyprint) when it is on PATH,
# otherwise fall back to the project virtualenv.
resolve_pdf_engine() {
  local project_root="$1"
  PDF_ENGINE="${PDF_ENGINE:-weasyprint}"
  if ! command -v "${PDF_ENGINE}" >/dev/null 2>&1 \
    && [ -x "${project_root}/.venv/bin/weasyprint" ]; then
    PDF_ENGINE="${project_root}/.venv/bin/weasyprint"
  fi
}

# Fail unless the resolved engine actually runs. A virtualenv whose
# interpreter moved, or a WeasyPrint missing Pango, passes an -x test
# but cannot render.
require_pdf_engine() {
  resolve_pdf_engine "$1"
  if ! "${PDF_ENGINE}" --version >/dev/null 2>&1; then
    echo "Missing or broken: ${PDF_ENGINE}" >&2
    echo "  Recreate it: python3 -m venv .venv && .venv/bin/pip install -r requirements.txt" >&2
    return 1
  fi
}
