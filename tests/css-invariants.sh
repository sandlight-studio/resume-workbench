#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '@page' "${ROOT}/styles/base-common.css"
grep -q 'size: A4' "${ROOT}/styles/base-common.css"
grep -q 'break-inside: avoid' "${ROOT}/styles/base-common.css"
grep -q 'LXGW WenKai' "${ROOT}/styles/base-wenkai.css"

if grep -Rqi 'TsangerJinKai\|仓耳今楷' "${ROOT}/styles"; then
  echo "FAIL: commercial font reference found" >&2
  exit 1
fi

echo "CSS invariants passed."
