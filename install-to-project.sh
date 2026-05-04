#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-$(pwd)}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p \
  "${TARGET_DIR}/.claude/skills/android-agent-standards" \
  "${TARGET_DIR}/.codex/skills/android-agent-standards" \
  "${TARGET_DIR}/.cursor/rules" \
  "${TARGET_DIR}/.github"

cp "${KIT_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"
cp "${KIT_DIR}/.claude/CLAUDE.md" "${TARGET_DIR}/.claude/CLAUDE.md"
cp "${KIT_DIR}/.claude/skills/android-agent-standards/SKILL.md" "${TARGET_DIR}/.claude/skills/android-agent-standards/SKILL.md"
cp "${KIT_DIR}/.codex/AGENTS.md" "${TARGET_DIR}/.codex/AGENTS.md"
cp "${KIT_DIR}/.codex/skills/android-agent-standards/SKILL.md" "${TARGET_DIR}/.codex/skills/android-agent-standards/SKILL.md"
cp "${KIT_DIR}/.github/pull_request_template.md" "${TARGET_DIR}/.github/pull_request_template.md"
cp "${KIT_DIR}/.cursor/rules/jetpack-compose-standards.mdc" "${TARGET_DIR}/.cursor/rules/jetpack-compose-standards.mdc"
cp "${KIT_DIR}/.cursor/rules/planning-large-changes.mdc" "${TARGET_DIR}/.cursor/rules/planning-large-changes.mdc"

if [ -d "${TARGET_DIR}/.git" ]; then
  EXCLUDE_FILE="${TARGET_DIR}/.git/info/exclude"
  touch "${EXCLUDE_FILE}"

  for pattern in "AGENTS.md" ".claude/" ".codex/" ".cursor/" ".github/pull_request_template.md"; do
    if ! grep -Fxq "${pattern}" "${EXCLUDE_FILE}"; then
      printf "%s\n" "${pattern}" >> "${EXCLUDE_FILE}"
    fi
  done

  echo "Added local git excludes for AGENTS.md, .claude/, .codex/, .cursor/, and .github/pull_request_template.md"
else
  echo "Target is not a git repo, so no local git excludes were added"
fi

echo "Installed Android agent kit into ${TARGET_DIR}"
