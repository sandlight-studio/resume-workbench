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

rm -f secret.txt
git add -A .

# Personal mode relaxes the contact rules for private forks. It must not
# relax anything else, or the escape hatch becomes a hole.
printf '%s%s\n' 'real.person@' 'company.test' > sample.md
git add sample.md
if bash scripts/privacy-check.sh >/dev/null 2>&1; then
  echo "FAIL: real email was not rejected in default mode" >&2
  exit 1
fi
RESUME_WORKBENCH_PERSONAL=1 bash scripts/privacy-check.sh >/dev/null || {
  echo "FAIL: personal mode did not allow a real email" >&2
  exit 1
}

mkdir -p local
printf '%s\n' 'enabled' > local/.private-ok
bash scripts/privacy-check.sh >/dev/null || {
  echo "FAIL: local/.private-ok did not enable personal mode" >&2
  exit 1
}

printf '%s%s\n' 'github_' 'pat_1234567890abcdefghijklmnop' > secret.txt
git add secret.txt
if bash scripts/privacy-check.sh >/dev/null 2>&1; then
  echo "FAIL: personal mode did not reject a token-like value" >&2
  exit 1
fi
rm -f secret.txt
git add -A .

git add -f local/.private-ok
if bash scripts/privacy-check.sh >/dev/null 2>&1; then
  echo "FAIL: personal mode did not reject a tracked local/ file" >&2
  exit 1
fi

echo "Privacy-check regressions passed."
