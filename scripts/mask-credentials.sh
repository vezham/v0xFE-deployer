#!/bin/bash

# Import utility functions
source "$(dirname "$0")/utils/mask-value.sh"

# Validate input parameters
if [ "$#" -ne 4 ]; then
    echo "Error: Expected 4 arguments"
    echo "Usage: $0 GCP_PROJECT_ID VERCEL_TOKEN VERCEL_ORG_ID VERCEL_PROJECT_ID"
    exit 1
fi

# Get the credentials from arguments
GCP_PROJECT_ID=$1
VERCEL_TOKEN=$2
VERCEL_ORG_ID=$3
VERCEL_PROJECT_ID=$4

# Mask each credential
mask_value "$GCP_PROJECT_ID" "GCP_PROJECT_ID" || exit 1
mask_value "$VERCEL_TOKEN" "VERCEL_TOKEN" || exit 1
mask_value "$VERCEL_ORG_ID" "VERCEL_ORG_ID" || exit 1
mask_value "$VERCEL_PROJECT_ID" "VERCEL_PROJECT_ID" || exit 1

echo "All credentials have been masked successfully"