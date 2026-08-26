#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT}/config/variants.sh"
CN_SECTIONS=("## 岗位优势" "## 工作经历" "## 项目经历" "## 技术能力" "## 教育背景" "## 自我评价")
EN_SECTIONS=("## Professional Summary" "## Work Experience" "## Selected Projects" "## Technical Skills" "## Education")

for variant in "${RESUME_VARIANTS[@]}"; do
  resolve_variant "${variant}"
  file="${ROOT}/resume/${SOURCE_FILE}"
  [ -f "${file}" ] || { echo "FAIL: missing ${file}" >&2; exit 1; }
  grep -q 'class="resume-header"' "${file}"
  if [ "${OUTPUT_MODE}" = "en" ]; then
    sections=("${EN_SECTIONS[@]}")
  else
    sections=("${CN_SECTIONS[@]}")
  fi
  for section in "${sections[@]}"; do
    grep -qxF "${section}" "${file}" || { echo "FAIL: ${variant} missing ${section}" >&2; exit 1; }
  done
  grep -Eq '^### .+ \| .+' "${file}" || { echo "FAIL: ${variant} has no project heading" >&2; exit 1; }
done

grep -q '全部是虚构' "${ROOT}/README.zh-CN.md"
grep -q 'fictional teaching examples' "${ROOT}/README.md"

echo "Content structure passed."
