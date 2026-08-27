#!/bin/bash

# Regenerate assets/resume-preview.png from the fictional default resume.
# Run after changing resume/zh/default.md or any print CSS.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ASSET_PATH="${PROJECT_ROOT}/assets/resume-preview.png"

command -v pandoc >/dev/null 2>&1 || { echo "Missing: pandoc" >&2; exit 1; }
command -v pdftoppm >/dev/null 2>&1 || { echo "Missing: pdftoppm (brew install poppler)" >&2; exit 1; }
PDF_ENGINE="${PDF_ENGINE:-weasyprint}"
command -v "${PDF_ENGINE}" >/dev/null 2>&1 || [ -x "${PROJECT_ROOT}/.venv/bin/weasyprint" ] \
  || { echo "Missing: ${PDF_ENGINE} (PATH or .venv/bin/weasyprint)" >&2; exit 1; }

BUILD_PATH_FILE="$(mktemp)"
cleanup() {
  rm -f "${BUILD_PATH_FILE}"
}
trap cleanup EXIT

BUILD_OUTPUT_PATH_FILE="${BUILD_PATH_FILE}" "${PROJECT_ROOT}/scripts/build.sh" default >/dev/null
PDF_PATH="$(cat "${BUILD_PATH_FILE}")"

# 288 DPI renders the A4 first page at 2382x3368 - crisp at 2x on retina
# displays while keeping the PNG under a few hundred kilobytes.
pdftoppm -png -r 288 -f 1 -l 1 -singlefile "${PDF_PATH}" "${ASSET_PATH%.png}"

echo "Preview refreshed: assets/resume-preview.png"
