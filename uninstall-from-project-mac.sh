#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Warning: uninstall-from-project-mac.sh is intended for macOS (Darwin)." >&2
fi

exec "${KIT_DIR}/uninstall-from-project.sh" "$@"
