#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_PATH_FILE="$(mktemp)"

cleanup() {
  rm -f "${BUILD_PATH_FILE}"
}
trap cleanup EXIT

BUILD_OUTPUT_PATH_FILE="${BUILD_PATH_FILE}" "${PROJECT_ROOT}/scripts/build.sh" "$@"
OUTPUT_FILE="$(cat "${BUILD_PATH_FILE}")"

echo "QA target: ${OUTPUT_FILE}"
if command -v pdftoppm >/dev/null 2>&1; then
  PREVIEW_ROOT="${PROJECT_ROOT}/dist/preview"
  pdftoppm -png -r 120 "${OUTPUT_FILE}" "${PREVIEW_ROOT}" >/dev/null 2>&1
  echo "Preview images: dist/preview-*.png"
else
  echo "pdftoppm not found; skipped preview rendering."
fi
