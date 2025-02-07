#!/bin/bash

source "./scripts/config.sh"
source "./scripts/utils.sh"

build_packages() {
    log_info "Building all packages..."
    pnpm build:fast
}

create_changeset() {
    log_info "Creating new changeset..."
    npx changeset
}

bump_versions() {
    log_info "Bumping versions..."
    npm run version
}

get_changed_packages() {
    log_info "Getting list of changed packages..."
    npx changeset status --output=json > "$CHANGESET_STATUS_FILE"
    
    # Wait for the file to be written
    sleep "$JSON_WAIT_TIME"
    
    if ! validate_json_file "$CHANGESET_STATUS_FILE"; then
        return 1
    fi
    
    local changed_packages
    changed_packages=$(jq -r '.releases[] | "\(.name)@\(.newVersion)"' "$CHANGESET_STATUS_FILE")
    
    if [ -z "$changed_packages" ]; then
        log_info "No packages have changes to publish"
        cleanup
        return 1
    fi
    
    echo "$changed_packages"
}

publish_package() {
    local package_name=$1
    local new_version=$2
    local package_dir
    
    package_dir=$(find packages -type d -name "$(basename "$package_name")")
    
    if [ -d "$package_dir" ]; then
        log_info "Publishing from directory: $package_dir"
        (cd "$package_dir" && npm publish --access public)
        return 0
    else
        log_warning "Could not find directory for package $package_name"
        return 1
    fi
}