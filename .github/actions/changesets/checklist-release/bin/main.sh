#!/bin/bash

# wjdlz/NOTE: Source all required scripts by DIR
source "$(dirname "$0")/index.sh"

main() {
    pre_setup

    get_package_info
    publish_packages
}

# Run main function
main
