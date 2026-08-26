#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
TEST_REPO="${TMP_DIR}/repo"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

mkdir -p "${TEST_REPO}/scripts"
cp "${ROOT}/scripts/privacy-check.sh" "${TEST_REPO}/scripts/privacy-check.sh"
cd "${TEST_REPO}"
git init -q

printf '%s\n' 'allowed@example.com' > sample.md
git add .
bash scripts/privacy-check.sh >/dev/null

printf '%s%s\n' 'allowed@example.com leaked@' 'company.test' > sample.md
git add sample.md
if bash scripts/privacy-check.sh >/dev/null 2>&1; then
  echo "FAIL: mixed-line real email was not rejected" >&2
  exit 1
fi

printf '%s%s\n' 'staged@' 'company.test' > sample.md
git add sample.md
printf '%s\n' 'clean@example.com' > sample.md
if bash scripts/privacy-check.sh >/dev/null 2>&1; then
  echo "FAIL: sensitive staged snapshot was not rejected" >&2
  exit 1
fi

git add sample.md
printf '%s%s\n' 'github_' 'pat_1234567890abcdefghijklmnop' > secret.txt
git add secret.txt
if bash scripts/privacy-check.sh >/dev/null 2>&1; then
  echo "FAIL: token-like value was not rejected" >&2
  exit 1
fi

echo "Privacy-check regressions passed."
