#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if npm list -g @github/copilot >/dev/null 2>&1; then
  echo "Uninstalling @github/copilot..."
  npm uninstall -g @github/copilot
  echo "Done."
fi

