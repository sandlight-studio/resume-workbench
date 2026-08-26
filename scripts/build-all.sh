#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/config/variants.sh"

for variant in "${RESUME_VARIANTS[@]}"; do
  "${SCRIPT_DIR}/build.sh" "${variant}"
done
