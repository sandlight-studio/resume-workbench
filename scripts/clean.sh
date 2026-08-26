#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIST_DIR="${PROJECT_ROOT}/dist"

case "${DIST_DIR}" in
  "${PROJECT_ROOT}/dist") ;;
  *) echo "Refusing to clean unexpected path: ${DIST_DIR}" >&2; exit 1 ;;
esac

[ -d "${DIST_DIR}" ] || exit 0
find "${DIST_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
