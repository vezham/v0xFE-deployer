#!/bin/bash

mask_value() {
    local value=$1
    local name=$2
    
    if [ -z "$value" ] || [ "$value" = "null" ]; then
        echo "Error: Invalid $name value"
        return 1
    fi
    
    echo "::add-mask::$value"
    return 0
}