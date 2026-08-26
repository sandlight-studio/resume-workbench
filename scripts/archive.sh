#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ARCHIVE_MONTH_DIR="${PROJECT_ROOT}/archive/$(date +%Y-%m)"
BUILD_PATH_FILE="$(mktemp)"

cleanup() {
  rm -f "${BUILD_PATH_FILE}"
}
trap cleanup EXIT

BUILD_OUTPUT_PATH_FILE="${BUILD_PATH_FILE}" "${PROJECT_ROOT}/scripts/build.sh" "$@"
OUTPUT_FILE="$(cat "${BUILD_PATH_FILE}")"

[ -n "${OUTPUT_FILE}" ] && [ -f "${OUTPUT_FILE}" ] \
  || { echo "Error: Build did not produce a PDF." >&2; exit 1; }

mkdir -p "${ARCHIVE_MONTH_DIR}"
cp "${OUTPUT_FILE}" "${ARCHIVE_MONTH_DIR}/$(basename "${OUTPUT_FILE}")"
echo "Archived: archive/$(date +%Y-%m)/$(basename "${OUTPUT_FILE}")"
