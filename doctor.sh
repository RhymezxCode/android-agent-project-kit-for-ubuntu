#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$(pwd)"
POSITIONAL_TARGET_SET=0

TOOLS_CSV="claude,codex,cursor,github"
CHECK_EXCLUDES=1

usage() {
  cat <<'EOF'
Usage:
  doctor.sh [target_dir] [options]

Options:
  --target <dir>         Target Android project directory.
  --tools <list>         Comma-separated: claude,codex,cursor,github,all
  --no-exclude-check     Skip .git/info/exclude checks.
  -h, --help             Show this help text.
EOF
}

die() {
  printf "Error: %s\n" "$1" >&2
  exit 1
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

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

check_file_exists() {
  local file_path="$1"
  if [ -f "${file_path}" ]; then
    printf "[PASS] %s exists\n" "${file_path}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    printf "[FAIL] %s is missing\n" "${file_path}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

check_exclude_line() {
  local file_path="$1"
  local expected_line="$2"
  if grep -Fxq "${expected_line}" "${file_path}"; then
    printf "[PASS] %s contains '%s'\n" "${file_path}" "${expected_line}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    printf "[FAIL] %s missing '%s'\n" "${file_path}" "${expected_line}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

check_exclude_line_unique() {
  local file_path="$1"
  local expected_line="$2"
  local count
  count="$(grep -Fxc "${expected_line}" "${file_path}" || true)"
  if [ "${count}" -le 1 ]; then
    printf "[PASS] %s has <=1 '%s' entry\n" "${file_path}" "${expected_line}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    printf "[FAIL] %s has duplicate '%s' entries (%s)\n" "${file_path}" "${expected_line}" "${count}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
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
    --no-exclude-check)
      CHECK_EXCLUDES=0
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

echo "Doctor target: ${TARGET_DIR}"
echo "Expected tools: ${TOOLS[*]}"
echo

check_file_exists "${TARGET_DIR}/AGENTS.md"

if has_tool "claude" "${TOOLS[@]}"; then
  check_file_exists "${TARGET_DIR}/.claude/CLAUDE.md"
  check_file_exists "${TARGET_DIR}/.claude/skills/android-agent-standards/SKILL.md"
fi

if has_tool "codex" "${TOOLS[@]}"; then
  check_file_exists "${TARGET_DIR}/.codex/skills/android-agent-standards/SKILL.md"
fi

if has_tool "cursor" "${TOOLS[@]}"; then
  check_file_exists "${TARGET_DIR}/.cursor/rules/jetpack-compose-standards.mdc"
  check_file_exists "${TARGET_DIR}/.cursor/rules/planning-large-changes.mdc"
fi

if has_tool "github" "${TOOLS[@]}"; then
  check_file_exists "${TARGET_DIR}/.github/pull_request_template.md"
fi

if [ "${CHECK_EXCLUDES}" -eq 1 ]; then
  if [ -d "${TARGET_DIR}/.git" ] && [ -f "${TARGET_DIR}/.git/info/exclude" ]; then
    EXCLUDE_FILE="${TARGET_DIR}/.git/info/exclude"
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
      check_exclude_line "${EXCLUDE_FILE}" "${pattern}"
      check_exclude_line_unique "${EXCLUDE_FILE}" "${pattern}"
    done
  else
    echo "[WARN] .git/info/exclude not found; skipped exclude checks."
    WARN_COUNT=$((WARN_COUNT + 1))
  fi
fi

echo
echo "Summary: ${PASS_COUNT} passed, ${FAIL_COUNT} failed, ${WARN_COUNT} warnings."

if [ "${FAIL_COUNT}" -gt 0 ]; then
  exit 1
fi
