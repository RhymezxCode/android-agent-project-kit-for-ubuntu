#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$(pwd)"
POSITIONAL_TARGET_SET=0

DRY_RUN=0
NO_EXCLUDE_CLEANUP=0
KEEP_AGENTS=0
TOOLS_CSV="claude,codex,cursor,github"

usage() {
  cat <<'EOF'
Usage:
  uninstall-from-project.sh [target_dir] [options]

Options:
  --target <dir>             Target Android project directory.
  --tools <list>             Comma-separated: claude,codex,cursor,github,all
  --keep-agents              Keep root AGENTS.md in place.
  --dry-run                  Print planned actions without modifying files.
  --no-exclude-cleanup       Skip removing entries from .git/info/exclude.
  -h, --help                 Show this help text.
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

remove_file_if_exists() {
  local file_path="$1"
  if [ -f "${file_path}" ]; then
    run_cmd rm -f "${file_path}"
  fi
}

remove_line_if_present() {
  local line="$1"
  local file_path="$2"

  [ -f "${file_path}" ] || return 0
  if ! grep -Fxq "${line}" "${file_path}"; then
    return 0
  fi

  if [ "${DRY_RUN}" -eq 1 ]; then
    printf "[dry-run] remove '%s' from %s\n" "${line}" "${file_path}"
    return 0
  fi

  local tmp_file
  tmp_file="${file_path}.tmp.$$"
  awk -v needle="${line}" '$0 != needle' "${file_path}" > "${tmp_file}"
  mv "${tmp_file}" "${file_path}"
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
    --keep-agents)
      KEEP_AGENTS=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-exclude-cleanup)
      NO_EXCLUDE_CLEANUP=1
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

if [ "${KEEP_AGENTS}" -eq 0 ]; then
  remove_file_if_exists "${TARGET_DIR}/AGENTS.md"
fi

if has_tool "claude" "${TOOLS[@]}"; then
  remove_file_if_exists "${TARGET_DIR}/.claude/CLAUDE.md"
  remove_file_if_exists "${TARGET_DIR}/.claude/skills/android-agent-standards/SKILL.md"
fi

if has_tool "codex" "${TOOLS[@]}"; then
  remove_file_if_exists "${TARGET_DIR}/.codex/skills/android-agent-standards/SKILL.md"
fi

if has_tool "cursor" "${TOOLS[@]}"; then
  remove_file_if_exists "${TARGET_DIR}/.cursor/rules/jetpack-compose-standards.mdc"
  remove_file_if_exists "${TARGET_DIR}/.cursor/rules/planning-large-changes.mdc"
fi

if has_tool "github" "${TOOLS[@]}"; then
  remove_file_if_exists "${TARGET_DIR}/.github/pull_request_template.md"
fi

if [ "${DRY_RUN}" -eq 0 ]; then
  rmdir "${TARGET_DIR}/.claude/skills/android-agent-standards" 2>/dev/null || true
  rmdir "${TARGET_DIR}/.claude/skills" 2>/dev/null || true
  rmdir "${TARGET_DIR}/.claude" 2>/dev/null || true
  rmdir "${TARGET_DIR}/.codex/skills/android-agent-standards" 2>/dev/null || true
  rmdir "${TARGET_DIR}/.codex/skills" 2>/dev/null || true
  rmdir "${TARGET_DIR}/.codex" 2>/dev/null || true
  rmdir "${TARGET_DIR}/.cursor/rules" 2>/dev/null || true
  rmdir "${TARGET_DIR}/.cursor" 2>/dev/null || true
  rmdir "${TARGET_DIR}/.github" 2>/dev/null || true
fi

if [ "${NO_EXCLUDE_CLEANUP}" -eq 1 ]; then
  echo "Skipped .git/info/exclude cleanup (--no-exclude-cleanup)."
elif [ -d "${TARGET_DIR}/.git" ]; then
  EXCLUDE_FILE="${TARGET_DIR}/.git/info/exclude"
  [ -f "${EXCLUDE_FILE}" ] || EXCLUDE_FILE=""
  if [ -n "${EXCLUDE_FILE}" ]; then
    if [ "${KEEP_AGENTS}" -eq 0 ]; then
      remove_line_if_present "AGENTS.md" "${EXCLUDE_FILE}"
    fi
    if has_tool "claude" "${TOOLS[@]}"; then
      remove_line_if_present ".claude/" "${EXCLUDE_FILE}"
    fi
    if has_tool "codex" "${TOOLS[@]}"; then
      remove_line_if_present ".codex/" "${EXCLUDE_FILE}"
    fi
    if has_tool "cursor" "${TOOLS[@]}"; then
      remove_line_if_present ".cursor/" "${EXCLUDE_FILE}"
    fi
    if has_tool "github" "${TOOLS[@]}"; then
      remove_line_if_present ".github/pull_request_template.md" "${EXCLUDE_FILE}"
    fi
  fi
else
  echo "Target is not a git repo, so no exclude cleanup was needed."
fi

echo "Uninstalled Android agent kit content from ${TARGET_DIR} (tools: ${TOOLS[*]})."
