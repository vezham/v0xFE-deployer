#!/bin/bash
set -euo pipefail

# Function to check if jq command exists
check_dependencies() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed" >&2
    exit 1
  fi
}

pnpm changeset status
