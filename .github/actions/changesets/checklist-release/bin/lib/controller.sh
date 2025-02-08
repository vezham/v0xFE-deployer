#!/bin/bash

IFS=$'\n\t'

get_package_info() {
  log_debug "Getting modified package.json files"
  local files=$(git diff --name-only HEAD^ HEAD | grep "package.json" || true)
  
  if [ -z "$files" ]; then
    log_info "No package.json files were modified"
    echo "[]" > "$CHANGESET_STATUS_JSON"
    return 0
  fi
  
  # Initialize JSON array
  echo "[" > "$CHANGESET_STATUS_JSON"
  local first=true
  local count=0
  
  while IFS= read -r file; do
    # Skip root package.json and invalid files
    [ "$file" = "package.json" ] && continue
    [ ! -f "$file" ] && continue
    
    log_debug "get_package_info | $file"
    if ! validate_json_file "$file"; then
      continue
    fi
    
    # Extract package info using jq
    local pkg_info=$(jq -r '{name: .name, version: .version, directory: $dir}' --arg dir "$(dirname "$file")" "$file")
    
    # Skip invalid packages
    if [ "$(echo "$pkg_info" | jq -r '.name')" = "null" ] || [ "$(echo "$pkg_info" | jq -r '.version')" = "null" ]; then
      continue
    fi

    # Add comma if not first item
    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> "$CHANGESET_STATUS_JSON"
    fi

    echo "$pkg_info" >> "$CHANGESET_STATUS_JSON"
    ((count++))
  done <<< "$files"

  # Close JSON array
  echo "]" >> "$CHANGESET_STATUS_JSON"

  if [ $count -gt 0 ]; then
    log_info "Found $count packages to publish → $CHANGESET_STATUS_JSON"
  fi
}

publish_packages() {
  if ! validate_json_file "$CHANGESET_STATUS_JSON"; then
    return 1
  fi

  local packages_json=$(cat "$CHANGESET_STATUS_JSON")
  local total_packages=$(echo "$packages_json" | jq length)

  if [ "$total_packages" -eq 0 ]; then
    log_info "No packages to publish"
    return 0
  fi

  publish_packages_in_batches $total_packages
}
