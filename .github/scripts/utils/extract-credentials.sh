#!/bin/bash

# Function to validate JSON values
validate_value() {
    local value=$1
    local name=$2
    
    if [ "$value" = "null" ] || [ -z "$value" ]; then
        echo "Error: $name not found in token file"
        return 1
    }
    return 0
}

# Extract credentials from token.json file
token_file=$1
output_file=$2

if [ ! -f "$token_file" ]; then
    echo "Error: Token file not found"
    exit 1
fi

# Extract all required values using jq
gcp_project_id=$(jq -r '.project_id' "$token_file")
vercel_token=$(jq -r '.VERCEL_TOKEN' "$token_file")
vercel_org_id=$(jq -r '.VERCEL_ORG_ID' "$token_file")
vercel_project_id=$(jq -r '.VERCEL_PROJECT_ID' "$token_file")

# Validate all values
validate_value "$gcp_project_id" "GCP_PROJECT_ID" || exit 1
validate_value "$vercel_token" "VERCEL_TOKEN" || exit 1
validate_value "$vercel_org_id" "VERCEL_ORG_ID" || exit 1
validate_value "$vercel_project_id" "VERCEL_PROJECT_ID" || exit 1

# Write to GitHub output file
{
    echo "GCP_PROJECT_ID=$gcp_project_id"
    echo "VERCEL_TOKEN=$vercel_token"
    echo "VERCEL_ORG_ID=$vercel_org_id"
    echo "VERCEL_PROJECT_ID=$vercel_project_id"
} >> "$output_file"