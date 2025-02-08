#!/bin/bash

# Configuration | $V
readonly V_HOME_DIR=".vezham"

# Configuration | LOGS
readonly LOG_DIR="${V_HOME_DIR}/logs"
readonly LOG_FILE="${LOG_DIR}/release-$(date +'%Y%m%d-%H%M%S').log"

# Colors for output
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration | GIT variables
readonly GIT_BOT_EMAIL="github-actions[bot]@users.noreply.github.com"
readonly GIT_BOT_NAME="github-actions[bot]"

# ------ MODULE BASED CONFIG FUN ------

# Configuration variables
BATCH_SIZE=3   #[20] # Number of packages to publish in each batch
BATCH_DELAY=30 #[300] # Delay between batches in seconds (5 minutes)
PACKAGE_DELAY=1 #[10] Delay between individual packages in seconds 

# Status file
readonly CHANGESET_STATUS_JSON="${V_HOME_DIR}/op-release-status.json"
readonly RELEASE_FAILED_JSON="${V_HOME_DIR}/op-release-status-failed.json"
