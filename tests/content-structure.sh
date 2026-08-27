#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

# The Python validator is the single source for section, project-field, and
# placeholder contracts; variant discovery stays in config/variants.sh.
python3 "${ROOT}/scripts/check-content.py" --root "${ROOT}"

grep -q '全部是虚构' "${ROOT}/README.zh-CN.md"
grep -q 'fictional teaching examples' "${ROOT}/README.md"

# Negative fixtures prove the contract rejects the two highest-risk omissions.
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT
cp -R "${ROOT}/resume" "${ROOT}/config" "${TMP_DIR}/"

printf '\n【待填】\n' >> "${TMP_DIR}/resume/zh/default.md"
if python3 "${ROOT}/scripts/check-content.py" --root "${TMP_DIR}" >/dev/null 2>&1; then
  fail "content contract must reject unresolved placeholders"
fi

cp "${ROOT}/resume/zh/default.md" "${TMP_DIR}/resume/zh/default.md"
python3 - "${TMP_DIR}/resume/zh/default.md" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
path.write_text(text.replace("**技术栈：**", "**缺失字段：**", 1), encoding="utf-8")
PY
if python3 "${ROOT}/scripts/check-content.py" --root "${TMP_DIR}" >/dev/null 2>&1; then
  fail "content contract must reject a missing project field"
fi

echo "Content structure passed."
