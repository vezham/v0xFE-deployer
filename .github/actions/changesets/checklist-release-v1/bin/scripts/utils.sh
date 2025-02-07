#!/bin/bash

source "./scripts/config.sh"

# Logging functions
log_message() {
    echo -e "[vezham] [$(date '+%Y-%m-%d %H:%M:%S')] $V_NS: $1" | tee -a "$LOG_FILE"
}

log_info() {
    log_message "${GREEN}INFO: $1${NC}"
}

log_warning() {
    log_message "${YELLOW}WARNING: $1${NC}"
}

log_error() {
    log_message "${RED}ERROR: $1${NC}"
}

# Validation functions
validate_json_file() {
    local file=$1
    
    if [ ! -s "$file" ]; then
        log_error "$file is empty or not found"
        return 1
    fi

    if ! jq empty "$file" 2>/dev/null; then
        log_error "Invalid JSON format in $file"
        return 1
    fi

    return 0
}

cleanup() {
    if [ -f "$CHANGESET_STATUS_FILE" ]; then
        rm "$CHANGESET_STATUS_FILE"
    fi
}