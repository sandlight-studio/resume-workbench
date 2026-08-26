#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

fail() {
  echo "PRIVACY CHECK FAILED: $1" >&2
  exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || fail "run this check inside a Git worktree"

forbidden_files="$(git ls-files | grep -Ei '(^|/)(dist|archive|local)/|\.(pdf|docx|ttf|otf)$|(^|/)\.env($|\.)' || true)"
[ -z "${forbidden_files}" ] || {
  printf '%s\n' "${forbidden_files}" >&2
  fail "generated, local, environment, or font artifacts are tracked"
}

email_hits="$(git grep --cached -hoEI '[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}' -- ':!scripts/privacy-check.sh' || true)"
if [ -n "${email_hits}" ]; then
  while IFS= read -r email; do
    [[ "${email}" == *"@example.com" ]] || {
      printf '%s\n' "${email}" >&2
      fail "non-example email address found"
    }
  done <<< "${email_hits}"
fi

phone_hits="$(git grep --cached -nE '(^|[^0-9])1[3-9][0-9]{9}([^0-9]|$)' -- '*.md' '*.sh' '*.json' '*.yml' '*.yaml' || true)"
[ -z "${phone_hits}" ] || {
  printf '%s\n' "${phone_hits}" >&2
  fail "possible mainland China mobile number found"
}

path_hits="$(git grep --cached -nE '/Users/|/home/[^ /]+/' -- ':!scripts/privacy-check.sh' || true)"
[ -z "${path_hits}" ] || {
  printf '%s\n' "${path_hits}" >&2
  fail "machine-specific home path found"
}

secret_hits="$(git grep --cached -nEI '(-----BEGIN ([A-Z ]+ )?PRIVATE KEY-----|github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|(api[_-]?key|access[_-]?token|client[_-]?secret|password)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9_./+-]{12,})' -- ':!scripts/privacy-check.sh' || true)"
[ -z "${secret_hits}" ] || {
  printf '%s\n' "${secret_hits}" >&2
  fail "possible hard-coded credential found"
}

echo "Privacy checks passed."
