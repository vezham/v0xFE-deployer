#!/bin/bash

# wjdlz/NOTE: Source all required scripts by DIR
source "$(dirname "$0")/scripts/config.sh"

# ------ MODULE BASED COMMON FUN ------

cleanup() {
    log_info "Executing cleanup!..."
    # if [ -f "$CHANGESET_STATUS_JSON" ]; then
    #     rm "$CHANGESET_STATUS_JSON"
    # fi

    # --------- CLOSING LOG INFO ---------
    log_info "Full logs available at: $LOG_FILE"
}