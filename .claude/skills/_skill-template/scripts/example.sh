#!/bin/bash
# [SKILL_NAME] - [Brief description]
# Usage: ./example.sh [args]

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Input Validation ---
if [[ $# -lt 1 ]]; then
    echo "ERROR: Missing required argument" >&2
    echo "Usage: $0 <arg1> [arg2]" >&2
    exit 1
fi

ARG1="$1"
ARG2="${2:-default_value}"

# --- Main Logic ---
main() {
    # TODO: Implement skill logic here
    echo "Executing skill with: $ARG1, $ARG2"

    # Return minimal success signal
    echo "SUCCESS"
    exit 0
}

# --- Error Handler ---
trap 'echo "FAILURE: Line $LINENO" >&2; exit 1' ERR

main "$@"
