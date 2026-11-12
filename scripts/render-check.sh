#!/bin/bash

# Build every variant with the real toolchain and fail when a PDF is empty
# or overflows RESUME_MAX_PAGES. The stubbed pandoc in tests/ cannot catch
# layout regressions; this can.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/config/variants.sh"
MAX_PAGES="${RESUME_MAX_PAGES:-1}"
BUILD_PATH_FILE="$(mktemp)"

cleanup() {
  rm -f "${BUILD_PATH_FILE}"
}
trap cleanup EXIT

command -v pdfinfo >/dev/null 2>&1 || { echo "Missing: pdfinfo (poppler)" >&2; exit 1; }
bash "${SCRIPT_DIR}/check.sh" >/dev/null

failed=0
for variant in "${RESUME_VARIANTS[@]}"; do
  BUILD_OUTPUT_PATH_FILE="${BUILD_PATH_FILE}" bash "${SCRIPT_DIR}/build.sh" "${variant}" >/dev/null
  pdf="$(cat "${BUILD_PATH_FILE}")"
  pages="$(pdfinfo "${pdf}" | awk '/^Pages:/ { print $2 }')"
  if [ -z "${pages}" ] || [ "${pages}" -lt 1 ] || [ "${pages}" -gt "${MAX_PAGES}" ]; then
    echo "FAIL: ${variant} rendered ${pages:-0} page(s); limit is ${MAX_PAGES}" >&2
    failed=1
  else
    echo "ok: ${variant} (${pages} page(s))"
  fi
done

[ "${failed}" -eq 0 ] || exit 1
echo "Render checks passed."
