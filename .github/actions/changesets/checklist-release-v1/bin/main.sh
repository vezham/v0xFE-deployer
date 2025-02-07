#!/bin/bash

# Source all required scripts
source "./scripts/config.sh"
source "./scripts/utils.sh"
source "./scripts/package-management.sh"
source "./scripts/batch-publisher.sh"

pre_setup(){
  # Set up error handling
  set -e
  trap cleanup EXIT

  # pre-setup
  mkdir .vezham
  # node v/bin/ci/npm/scripts/check-publish.js # wjdlz pnpm v:g:check-publish

  # Initialize logging
  setup_logging
}

main() {
    pre_setup
    
    # -----
    PACKAGES=$(get_package_info)
    if [ ! -z "$PACKAGES" ]; then
      publish_packages "$PACKAGES"
    else
      log_info "No packages to publish"
    fi
    
    # -----
    # Build and prepare packages
    build_packages
    create_changeset
    bump_versions
    
    # Get changed packages
    local changed_packages
    if ! changed_packages=$(get_changed_packages); then
        exit 1
    fi
    
    # Process packages in batches
    process_packages_in_batches "$changed_packages"
    
    log_info "Done! All changed packages have been published in batches."
}

# Run main function
main