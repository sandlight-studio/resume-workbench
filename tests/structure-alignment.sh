#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT}/config/variants.sh"
TMP_DIR="$(mktemp -d)"
FAKE_BIN="${TMP_DIR}/bin"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

mkdir -p "${FAKE_BIN}" "${TMP_DIR}/repo/.venv/bin"
cp -R "${ROOT}/config" "${ROOT}/resume" "${ROOT}/styles" "${ROOT}/scripts" "${TMP_DIR}/repo/"

cat > "${FAKE_BIN}/pandoc" <<'FAKE_PANDOC'
#!/bin/bash
set -euo pipefail
output=""
while [ "$#" -gt 0 ]; do
  if [ "$1" = "-o" ]; then
    output="$2"
    shift 2
  else
    shift
  fi
done
[ -n "${output}" ] || exit 1
mkdir -p "$(dirname "${output}")"
printf '%%PDF-FAKE-1.0\n' > "${output}"
FAKE_PANDOC
chmod +x "${FAKE_BIN}/pandoc"

cat > "${TMP_DIR}/repo/.venv/bin/weasyprint" <<'FAKE_WEASYPRINT'
#!/bin/bash
exit 0
FAKE_WEASYPRINT
chmod +x "${TMP_DIR}/repo/.venv/bin/weasyprint"

export PATH="${FAKE_BIN}:${PATH}"

for variant in "${RESUME_VARIANTS[@]}"; do
  output="$(cd "${TMP_DIR}/repo" && bash scripts/build.sh "${variant}" 2>&1)"
  [[ "${output}" == *"Build complete:"* ]] || { echo "FAIL: ${variant} did not build" >&2; exit 1; }
done

wenkai_output="$(cd "${TMP_DIR}/repo" && bash scripts/build.sh backend --font wenkai 2>&1)"
[[ "${wenkai_output}" == *"Font: wenkai"* ]]
[[ "${wenkai_output}" == *"WenKai"* ]]

override_output="$(cd "${TMP_DIR}/repo" && RESUME_NAME_EN='Candidate/Example' bash scripts/build.sh english 2>&1)"
[[ "${override_output}" == *"Candidate-Example-Resume"* ]]

if (cd "${TMP_DIR}/repo" && bash scripts/build.sh unknown >/dev/null 2>&1); then
  echo "FAIL: unsupported variant succeeded" >&2
  exit 1
fi

if (cd "${TMP_DIR}/repo" && bash scripts/build.sh java backend >/dev/null 2>&1); then
  echo "FAIL: multiple variants succeeded" >&2
  exit 1
fi

if (cd "${TMP_DIR}/repo" && bash scripts/build.sh default --unknown >/dev/null 2>&1); then
  echo "FAIL: unknown option succeeded" >&2
  exit 1
fi

if (cd "${TMP_DIR}/repo" && bash scripts/build.sh default --font commercial >/dev/null 2>&1); then
  echo "FAIL: unsupported font succeeded" >&2
  exit 1
fi

if (cd "${TMP_DIR}/repo" && bash scripts/build.sh default --font >/dev/null 2>&1); then
  echo "FAIL: missing font value succeeded" >&2
  exit 1
fi

(cd "${TMP_DIR}/repo" && bash scripts/archive.sh backend >/dev/null)
find "${TMP_DIR}/repo/archive" -type f -name '*.pdf' | grep -q .

echo "Script interfaces passed."
