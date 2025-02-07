#!/bin/bash

# Configuration
V_NS='wjdlz/WS'
LOG_FILE="log-publish-$(date '+%Y-%m-%d %H:%M:%S').txt" # .vezham/log-

# Configuration variables
BATCH_SIZE=3   #[20] # Number of packages to publish in each batch
BATCH_DELAY=30 #[300] # Delay between batches in seconds (5 minutes)
PACKAGE_DELAY=0 #[10] Delay between individual packages in seconds 
JSON_WAIT_TIME=2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Status file
CHANGESET_STATUS_FILE="changeset-status.json" # JSON_FILE=".vezham/publish-check-result.json"
