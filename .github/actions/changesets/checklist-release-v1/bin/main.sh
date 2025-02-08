#!/bin/bash

# wjdlz/NOTE: Source all required scripts by DIR
source "$(dirname "$0")/scripts/utils-log.sh"
source "$(dirname "$0")/scripts/utils.sh"
source "$(dirname "$0")/github-actions.sh"

pre_setup(){
  # Set strict mode, error handling
  # set -euo pipefail
  trap cleanup EXIT

  # Initialize logging
  setup_logging
}

main() {
    pre_setup

    get_package_info
    publish_packages
}

# Run main function
main