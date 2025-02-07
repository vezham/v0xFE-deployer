#!/bin/bash

# wjdlz/NOTE: Source all required scripts by DIR
source "$(dirname "$0")/scripts/config.sh"
source "$(dirname "$0")/scripts/utils-helper.sh"
source "$(dirname "$0")/scripts/utils-git.sh"

IFS=$'\n\t'

get_package_info() {
  log_debug "Getting modified package.json files"
  local files
  files=$(git diff --name-only HEAD^ HEAD | grep "package.json" || true)
  
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
    local pkg_info
    pkg_info=$(jq -r '{name: .name, version: .version, directory: $dir}' --arg dir "$(dirname "$file")" "$file")
    
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
    log_info "Found $count packages to process → $CHANGESET_STATUS_JSON"
  fi
}

do_publish() {
  local package_name=$1
  local new_version=$2
  local package_dir=$3

  if [ ! -d "$package_dir" ]; then
    log_error "Directory not found: $package_dir"
    return 1
  fi
  
  log_info "Publishing $package_name@$new_version → $package_dir"
  
  if ! (cd "$package_dir" && npm publish --dry-run --access public); then
    log_error "Failed to publish $package_name"
    return 1
  fi
  
  # create_git_tag "$package_name" "$new_version"  # wjdlz/TODO: POC
  return 0
}

publish_packages() {
  if ! validate_json_file "$CHANGESET_STATUS_JSON"; then
      return 1
  fi

  local packages_json
  packages_json=$(cat "$CHANGESET_STATUS_JSON")
  local total_packages
  total_packages=$(echo "$packages_json" | jq length)

  if [ "$total_packages" -eq 0 ]; then
    log_info "No packages to publish"
    return 0
  fi
  
  # setup_git # wjdlz/TODO: set v0x-bot
  local current=0
  local failed=0

  # Initialize failed packages JSON array
  echo "[]" > "$RELEASE_FAILED_JSON"
  
  log_info "Starting to publish $total_packages packages"
  
  while [ $current -lt $total_packages ]; do
    local package_info
    package_info=$(echo "$packages_json" | jq -r ".[$current]")
    ((current++))
    
    local package_name
    local new_version
    local package_dir

    package_name=$(echo "$package_info" | jq -r '.name')
    new_version=$(echo "$package_info" | jq -r '.version')
    package_dir=$(echo "$package_info" | jq -r '.directory')
    
    log_info "Publishing $package_name ( $new_version → $current/$total_packages )"
    
    if ! do_publish "$package_name" "$new_version" "$package_dir"; then
      log_error "Failed to process $package_name, continuing with next package"
      ((failed++))

      # Add failed package to JSON array
      local temp_json
      temp_json=$(jq ". + [{\"name\": \"$package_name\", \"version\": \"$new_version\", \"directory\": \"$package_dir\"}]" "$RELEASE_FAILED_JSON")
      echo "$temp_json" > "$RELEASE_FAILED_JSON"
      continue
    fi
    
    # Wait between publishes if there are more packages
    if [ "$current" -lt "$total_packages" ]; then
      log_info "Waiting $PACKAGE_DELAY seconds before next package..."
      sleep "$PACKAGE_DELAY"
    fi
  done
  
  local total_published=$((current - failed))
  log_info "Completed publishing $total_published/$total_packages packages successfully ($failed failed)"
  
  if [ "$failed" -gt 0 ]; then
    log_info "Failed packages:"
    jq '.' "$RELEASE_FAILED_JSON"
  fi
}