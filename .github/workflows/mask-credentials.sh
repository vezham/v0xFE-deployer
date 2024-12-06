#!/bin/bash

# Get the credentials from arguments
GCP_PROJECT_ID=$1
VERCEL_TOKEN=$2
VERCEL_ORG_ID=$3
VERCEL_PROJECT_ID=$4

# Function to mask a value if it's not empty
mask_value() {
    local value=$1
    local name=$2
    
    if [ -z "$value" ]; then
        echo "Warning: No $name provided"
    else
        echo "::add-mask::$value"
        # echo "$name=$value" >> $GITHUB_ENV
        echo "$name has been masked in the logs"
    fi
}

# Mask each credential
mask_value "$GCP_PROJECT_ID" "GCP_PROJECT_ID"
mask_value "$VERCEL_TOKEN" "VERCEL_TOKEN"
mask_value "$VERCEL_ORG_ID" "VERCEL_ORG_ID"
mask_value "$VERCEL_PROJECT_ID" "VERCEL_PROJECT_ID"