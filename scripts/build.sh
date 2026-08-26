#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/config/variants.sh"

POSITION_KEY=""
FONT="${FONT:-serif}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --font)
      [ $# -ge 2 ] || { echo "Error: --font requires serif or wenkai." >&2; exit 1; }
      FONT="$2"
      shift 2
      ;;
    --*)
      echo "Error: Unsupported option '$1'." >&2
      echo "Usage: ./scripts/build.sh <variant> [--font serif|wenkai]" >&2
      exit 1
      ;;
    *)
      if [ -n "${POSITION_KEY}" ]; then
        echo "Error: Specify exactly one resume variant." >&2
        echo "Usage: ./scripts/build.sh <variant> [--font serif|wenkai]" >&2
        exit 1
      fi
      POSITION_KEY="$1"
      shift
      ;;
  esac
done

case "${FONT}" in
  serif|wenkai) ;;
  *)
    echo "Error: Unsupported font '${FONT}'." >&2
    echo "Usage: ./scripts/build.sh <variant> [--font serif|wenkai]" >&2
    exit 1
    ;;
esac

POSITION_KEY="${POSITION_KEY:-default}"
if ! resolve_variant "${POSITION_KEY}"; then
  echo "Error: Unsupported variant '${POSITION_KEY}'." >&2
  echo "Usage: ./scripts/build.sh <default|java|backend|fullstack|english> [--font serif|wenkai]" >&2
  exit 1
fi

safe_label() {
  printf '%s' "$1" | sed 's#[/\\:]#-#g; s/[[:cntrl:]]//g; s/^ *//; s/ *$//'
}

RESUME_NAME_ZH="$(safe_label "${RESUME_NAME_ZH:-张三}")"
RESUME_NAME_EN="$(safe_label "${RESUME_NAME_EN:-San-Zhang}")"
YOE_CN="$(safe_label "${YOE_CN:-5年}")"
YOE_EN="$(safe_label "${YOE_EN:-5YOE}")"

for required_value in "${RESUME_NAME_ZH}" "${RESUME_NAME_EN}" "${YOE_CN}" "${YOE_EN}"; do
  [ -n "${required_value}" ] || { echo "Error: Output labels cannot be empty." >&2; exit 1; }
done

SOURCE_PATH="${PROJECT_ROOT}/resume/${SOURCE_FILE}"
[ -f "${SOURCE_PATH}" ] || { echo "Error: resume/${SOURCE_FILE} not found." >&2; exit 1; }

DIST_DIR="${PROJECT_ROOT}/dist"
mkdir -p "${DIST_DIR}"
DATE="$(date +%Y%m%d)"
COMMON_CSS="${PROJECT_ROOT}/styles/base-common.css"
FONT_SUFFIX=""

if [ "${FONT}" = "wenkai" ]; then
  BASE_CSS="${PROJECT_ROOT}/styles/base-wenkai.css"
  FONT_SUFFIX="-WenKai"
elif [ "${OUTPUT_MODE}" = "en" ]; then
  BASE_CSS="${PROJECT_ROOT}/styles/base-en.css"
else
  BASE_CSS="${PROJECT_ROOT}/styles/base.css"
fi

if [ "${OUTPUT_MODE}" = "en" ]; then
  THEME_CSS="${PROJECT_ROOT}/styles/theme-english.css"
  OUTPUT_FILE="${DIST_DIR}/${RESUME_NAME_EN}-Resume-${DATE}-${OUTPUT_SLUG}${FONT_SUFFIX}-${YOE_EN}.pdf"
else
  THEME_CSS="${PROJECT_ROOT}/styles/theme-conservative.css"
  OUTPUT_FILE="${DIST_DIR}/${RESUME_NAME_ZH}-简历-${DATE}_${POSITION}${FONT_SUFFIX}_${YOE_CN}.pdf"
fi

PDF_ENGINE="${PDF_ENGINE:-weasyprint}"
if ! command -v "${PDF_ENGINE}" >/dev/null 2>&1; then
  if [ -x "${PROJECT_ROOT}/.venv/bin/weasyprint" ]; then
    PDF_ENGINE="${PROJECT_ROOT}/.venv/bin/weasyprint"
  fi
fi

echo "Building resume..."
echo "  Source: resume/${SOURCE_FILE}"
echo "  Position: ${POSITION}"
echo "  Font: ${FONT}"
echo "  Output: dist/$(basename "${OUTPUT_FILE}")"

pandoc "${SOURCE_PATH}" \
  -o "${OUTPUT_FILE}" \
  --pdf-engine="${PDF_ENGINE}" \
  --metadata="pagetitle:${POSITION}" \
  --css="${COMMON_CSS}" \
  --css="${BASE_CSS}" \
  --css="${THEME_CSS}"

if [ -n "${BUILD_OUTPUT_PATH_FILE:-}" ]; then
  printf '%s\n' "${OUTPUT_FILE}" > "${BUILD_OUTPUT_PATH_FILE}"
fi

echo "Build complete: ${OUTPUT_FILE}"
