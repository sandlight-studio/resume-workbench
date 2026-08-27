#!/bin/bash

# Read-only survey of one author's contributions across local repositories.
# Writes nothing to the repositories it inspects; prints a report to stdout.

set -euo pipefail

MAX_SUBJECTS=200
SINCE=""
AUTHORS=()
REPOS=()

usage() {
  cat >&2 <<'EOF'
Usage: scripts/mine-commits.sh --author <pattern> [--author <pattern>]... \
                               [--since <date>] [--max-subjects <n>] \
                               <repo-path> [<repo-path>...]

  --author        Author name or email pattern. Repeat for people who commit
                  under several identities; git treats them as OR.
  --since         Passed to git log, e.g. "2 years ago" or 2024-01-01.
  --max-subjects  Commit subjects to print per repository (default 200).

Run `git -C <repo> shortlog -sne --all` first if you are unsure which identity
string to match.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --author)
      [ $# -ge 2 ] || { echo "Error: --author requires a pattern." >&2; usage; }
      AUTHORS+=("$2")
      shift 2
      ;;
    --since)
      [ $# -ge 2 ] || { echo "Error: --since requires a date." >&2; usage; }
      SINCE="$2"
      shift 2
      ;;
    --max-subjects)
      [ $# -ge 2 ] || { echo "Error: --max-subjects requires a number." >&2; usage; }
      case "$2" in
        ''|*[!0-9]*) echo "Error: --max-subjects must be a number." >&2; usage ;;
      esac
      MAX_SUBJECTS="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    --*)
      echo "Error: Unsupported option '$1'." >&2
      usage
      ;;
    *)
      REPOS+=("$1")
      shift
      ;;
  esac
done

[ ${#AUTHORS[@]} -gt 0 ] || { echo "Error: at least one --author is required." >&2; usage; }
[ ${#REPOS[@]} -gt 0 ] || { echo "Error: at least one repository path is required." >&2; usage; }

FILTER_ARGS=()
for author in "${AUTHORS[@]}"; do
  FILTER_ARGS+=("--author=${author}")
done
FILTER_ARGS+=(--regexp-ignore-case)
[ -z "${SINCE}" ] || FILTER_ARGS+=("--since=${SINCE}")

STACK_MARKERS=(
  package.json pom.xml go.mod Cargo.toml requirements.txt pyproject.toml
  Gemfile composer.json build.gradle build.gradle.kts settings.gradle
  Dockerfile docker-compose.yml docker-compose.yaml Makefile
  tsconfig.json next.config.js vite.config.ts pnpm-lock.yaml
)

rule() {
  printf '%s\n' "------------------------------------------------------------"
}

for repo in "${REPOS[@]}"; do
  if [ ! -d "${repo}" ]; then
    echo "Error: '${repo}' is not a directory." >&2
    exit 1
  fi
  if ! git -C "${repo}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: '${repo}' is not a Git repository." >&2
    exit 1
  fi

  repo_root="$(git -C "${repo}" rev-parse --show-toplevel)"
  repo_name="$(basename "${repo_root}")"
  # symbolic-ref reports the branch even before the first commit, where
  # rev-parse --abbrev-ref prints a bare "HEAD" and fails at the same time.
  branch="$(git -C "${repo}" symbolic-ref --short HEAD 2>/dev/null || echo "detached")"

  rule
  echo "REPOSITORY: ${repo_name}"
  echo "Branch: ${branch}"
  echo "Authors matched: ${AUTHORS[*]}"
  [ -z "${SINCE}" ] || echo "Since: ${SINCE}"
  rule

  # A repository with no commits yet makes git log fail; pipefail would then
  # abort the whole run instead of reporting an empty repository.
  commit_count="$({ git -C "${repo}" log "${FILTER_ARGS[@]}" --format='%H' 2>/dev/null || true; } | wc -l | tr -d ' ')"

  if [ "${commit_count}" = "0" ]; then
    echo "No commits matched these authors."
    echo
    echo "Identities present in this repository:"
    git -C "${repo}" shortlog -sne --all 2>/dev/null | head -20 || true
    echo
    echo "Re-run with --author set to one of the strings above."
    echo
    continue
  fi

  # head closes the pipe early, so every `| head` needs a pipefail guard.
  first_date="$(git -C "${repo}" log "${FILTER_ARGS[@]}" --format='%ad' --date=short --reverse | head -1 || true)"
  last_date="$(git -C "${repo}" log "${FILTER_ARGS[@]}" --format='%ad' --date=short | head -1 || true)"
  active_months="$(git -C "${repo}" log "${FILTER_ARGS[@]}" --format='%ad' --date=format:'%Y-%m' | sort -u | wc -l | tr -d ' ')"

  echo "## Scale"
  echo "Commits: ${commit_count}"
  echo "First commit: ${first_date}"
  echo "Last commit: ${last_date}"
  echo "Active months: ${active_months}"

  git -C "${repo}" log "${FILTER_ARGS[@]}" --numstat --format='' \
    | awk '
        NF == 3 && $1 != "-" { add += $1; del += $2; files[$3] = 1 }
        END {
          count = 0
          for (f in files) count++
          printf "Lines added: %d\nLines deleted: %d\nDistinct files touched: %d\n", add, del, count
        }
      '
  echo

  echo "## Commits per month"
  git -C "${repo}" log "${FILTER_ARGS[@]}" --format='%ad' --date=format:'%Y-%m' \
    | sort | uniq -c | sort -k2 | awk '{printf "%s  %s\n", $2, $1}'
  echo

  echo "## Most touched areas (path depth 2)"
  git -C "${repo}" log "${FILTER_ARGS[@]}" --name-only --format='' \
    | awk 'NF' \
    | awk -F/ 'NF >= 2 { print $1 "/" $2 } NF == 1 { print $1 }' \
    | sort | uniq -c | sort -rn | head -20 \
    | awk '{printf "%6s  %s\n", $1, $2}' || true
  echo
  echo "Note: lockfiles, generated clients, and vendored directories inflate"
  echo "this list. High churn is not the same as high signal."
  echo

  echo "## Commit subject prefixes"
  prefixes="$(git -C "${repo}" log "${FILTER_ARGS[@]}" --format='%s' \
    | grep -oE '^[a-zA-Z]+(\([^)]*\))?!?:' \
    | sed 's/(.*//; s/!//; s/://' \
    | tr '[:upper:]' '[:lower:]' \
    | sort | uniq -c | sort -rn || true)"
  if [ -n "${prefixes}" ]; then
    printf '%s\n' "${prefixes}" | awk '{printf "%6s  %s\n", $1, $2}'
  else
    echo "No conventional-commit prefixes found."
  fi
  echo

  echo "## Stack markers present in the working tree"
  found_marker=0
  for marker in "${STACK_MARKERS[@]}"; do
    if [ -e "${repo_root}/${marker}" ]; then
      echo "  ${marker}"
      found_marker=1
    fi
  done
  if git -C "${repo}" ls-files '*.tf' 2>/dev/null | head -1 | grep -q .; then
    echo "  *.tf (Terraform)"
    found_marker=1
  fi
  [ "${found_marker}" = "1" ] || echo "  none detected at the repository root"
  echo

  echo "## Subjects (most recent ${MAX_SUBJECTS})"
  git -C "${repo}" log "${FILTER_ARGS[@]}" --format='%ad  %s' --date=short \
    | head -n "${MAX_SUBJECTS}" || true
  echo
done
