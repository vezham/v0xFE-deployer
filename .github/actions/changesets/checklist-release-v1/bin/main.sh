#!/bin/bash

# Source all required scripts
source ./scripts/github-actions.sh
          
# Initialize logging
setup_logging

PACKAGES=$(get_package_info)

if [ ! -z "$PACKAGES" ]; then
    publish_packages "$PACKAGES"
else
    log_info "No packages to publish"
fi
