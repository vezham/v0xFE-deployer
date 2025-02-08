#!/bin/bash

# Validation | .json file
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
