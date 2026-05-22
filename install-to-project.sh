#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"
POSITIONAL_TARGET_SET=0

DRY_RUN=0
NO_EXCLUDE=0
BACKUP_EXISTING=0
TOOLS_CSV="claude,codex,cursor,github"

usage() {
  cat <<'EOF'
Usage:
  install-to-project.sh [target_dir] [options]

Options:
  --target <dir>         Target Android project directory.
  --tools <list>         Comma-separated: claude,codex,cursor,github,all
  --dry-run              Print planned actions without modifying files.
  --no-exclude           Skip .git/info/exclude updates.
  --backup-existing      Create timestamped .bak copies before overwriting files.
  -h, --help             Show this help text.
EOF
}

die() {
  printf "Error: %s\n" "$1" >&2
  exit 1
}

run_cmd() {
  if [ "${DRY_RUN}" -eq 1 ]; then
    printf "[dry-run] %s\n" "$*"
  else
    "$@"
  fi
}

has_tool() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [ "${item}" = "${needle}" ] && return 0
  done
  return 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --target)
      [ "$#" -ge 2 ] || die "--target requires a directory value."
      TARGET_DIR="$2"
      shift 2
      ;;
    --tools)
      [ "$#" -ge 2 ] || die "--tools requires a comma-separated value."
      TOOLS_CSV="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-exclude)
      NO_EXCLUDE=1
      shift
      ;;
    --backup-existing)
      BACKUP_EXISTING=1
      shift
      ;;
    --*)
      die "Unknown option: $1"
      ;;
    *)
      [ "${POSITIONAL_TARGET_SET}" -eq 0 ] || die "Multiple target directories provided."
      TARGET_DIR="$1"
      POSITIONAL_TARGET_SET=1
      shift
      ;;
  esac
done

[ -d "${TARGET_DIR}" ] || die "Target directory does not exist: ${TARGET_DIR}"

TOOLS_NORMALIZED=""
if [ "${TOOLS_CSV}" = "all" ]; then
  TOOLS_NORMALIZED="claude,codex,cursor,github"
else
  TOOLS_NORMALIZED="${TOOLS_CSV}"
fi

IFS=',' read -r -a REQUESTED_TOOLS <<< "${TOOLS_NORMALIZED}"
TOOLS=()
for raw_tool in "${REQUESTED_TOOLS[@]}"; do
  tool="$(printf "%s" "${raw_tool}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  [ -n "${tool}" ] || continue
  case "${tool}" in
    claude|codex|cursor|github)
      if ! has_tool "${tool}" "${TOOLS[@]:-}"; then
        TOOLS+=("${tool}")
      fi
      ;;
    *)
      die "Unsupported tool '${tool}'. Use claude,codex,cursor,github,all."
      ;;
  esac
done

[ "${#TOOLS[@]}" -gt 0 ] || die "No valid tools selected."

STAMP="$(date +%Y%m%d%H%M%S)"

copy_file() {
  local source_path="$1"
  local destination_path="$2"
  local destination_dir
  destination_dir="$(dirname "${destination_path}")"

  run_cmd mkdir -p "${destination_dir}"

  if [ "${BACKUP_EXISTING}" -eq 1 ] && [ -f "${destination_path}" ]; then
    run_cmd cp "${destination_path}" "${destination_path}.bak.${STAMP}"
  fi

  run_cmd cp "${source_path}" "${destination_path}"
}

copy_file "${KIT_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"

if has_tool "claude" "${TOOLS[@]}"; then
  copy_file "${KIT_DIR}/.claude/CLAUDE.md" "${TARGET_DIR}/.claude/CLAUDE.md"
  copy_file "${KIT_DIR}/.claude/skills/android-agent-standards/SKILL.md" "${TARGET_DIR}/.claude/skills/android-agent-standards/SKILL.md"
fi

if has_tool "codex" "${TOOLS[@]}"; then
  copy_file "${KIT_DIR}/.codex/skills/android-agent-standards/SKILL.md" "${TARGET_DIR}/.codex/skills/android-agent-standards/SKILL.md"
fi

if has_tool "cursor" "${TOOLS[@]}"; then
  copy_file "${KIT_DIR}/.cursor/rules/jetpack-compose-standards.mdc" "${TARGET_DIR}/.cursor/rules/jetpack-compose-standards.mdc"
  copy_file "${KIT_DIR}/.cursor/rules/planning-large-changes.mdc" "${TARGET_DIR}/.cursor/rules/planning-large-changes.mdc"
fi

if has_tool "github" "${TOOLS[@]}"; then
  copy_file "${KIT_DIR}/.github/pull_request_template.md" "${TARGET_DIR}/.github/pull_request_template.md"
fi

if [ "${NO_EXCLUDE}" -eq 1 ]; then
  echo "Skipped local git exclude updates (--no-exclude)."
elif [ -d "${TARGET_DIR}/.git" ]; then
  EXCLUDE_FILE="${TARGET_DIR}/.git/info/exclude"
  run_cmd touch "${EXCLUDE_FILE}"

  EXCLUDE_PATTERNS=("AGENTS.md")
  if has_tool "claude" "${TOOLS[@]}"; then
    EXCLUDE_PATTERNS+=(".claude/")
  fi
  if has_tool "codex" "${TOOLS[@]}"; then
    EXCLUDE_PATTERNS+=(".codex/")
  fi
  if has_tool "cursor" "${TOOLS[@]}"; then
    EXCLUDE_PATTERNS+=(".cursor/")
  fi
  if has_tool "github" "${TOOLS[@]}"; then
    EXCLUDE_PATTERNS+=(".github/pull_request_template.md")
  fi

  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    if grep -Fxq "${pattern}" "${EXCLUDE_FILE}"; then
      continue
    fi
    if [ "${DRY_RUN}" -eq 1 ]; then
      printf "[dry-run] append '%s' to %s\n" "${pattern}" "${EXCLUDE_FILE}"
    else
      printf "%s\n" "${pattern}" >> "${EXCLUDE_FILE}"
    fi
  done

  echo "Updated local git excludes for selected tools."
else
  echo "Target is not a git repo, so no local git excludes were added"
fi

echo "Installed Android agent kit into ${TARGET_DIR} (tools: ${TOOLS[*]})."
