#!/bin/bash

# wjdlz/NOTE: Source all required scripts by DIR
source "$(dirname "$0")/scripts/config.sh"
source "$(dirname "$0")/scripts/utils-log.sh"

process_packages_in_batches() {
    local changed_packages=$1
    local total_packages
    total_packages=$(echo "$changed_packages" | wc -l)
    
    log_info "Found $total_packages packages to publish"
    
    local current_package=0
    local batch_number=0
    
    echo "$changed_packages" | while read -r package_info; do
        [ -z "$package_info" ] && continue
        
        ((current_package++))
        
        local package_name
        local new_version
        package_name=$(echo "$package_info" | cut -d@ -f1)
        new_version=$(echo "$package_info" | cut -d@ -f2)
        
        batch_number=$(( (current_package - 1) / BATCH_SIZE + 1 ))
        position_in_batch=$(( (current_package - 1) % BATCH_SIZE + 1 ))
        
        log_info "Publishing package $current_package/$total_packages (Batch $batch_number, Position $position_in_batch):"
        log_info "  Name: $package_name"
        log_info "  Version: $new_version"
        
        if publish_package "$package_name" "$new_version"; then
            if [ $current_package -lt $total_packages ]; then
                if [ $position_in_batch -eq $BATCH_SIZE ]; then
                    log_info "End of batch $batch_number. Waiting $BATCH_DELAY seconds before next batch..."
                    sleep "$BATCH_DELAY"
                else
                    log_info "Waiting $PACKAGE_DELAY seconds before next package..."
                    sleep "$PACKAGE_DELAY"
                fi
            fi
        fi
    done
}