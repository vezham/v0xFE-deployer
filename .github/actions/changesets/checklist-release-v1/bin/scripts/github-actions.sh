#!/bin/bash

# Set strict mode
set -euo pipefail
IFS=$'\n\t'

# Constants
readonly WAIT_TIME=10
readonly GIT_BOT_EMAIL="github-actions[bot]@users.noreply.github.com"
readonly GIT_BOT_NAME="github-actions[bot]"
readonly LOG_DIR="logs"
readonly LOG_FILE="${LOG_DIR}/publish-$(date +'%Y%m%d-%H%M%S').log"

# Initialize logging
setup_logging() {
  mkdir -p "$LOG_DIR"
  touch "$LOG_FILE"
  log "INFO" "Log file created at $LOG_FILE"
}

# Logging functions
log() {
  local level=$1
  local message=$2
  local timestamp
  timestamp=$(date +'%Y-%m-%d %H:%M:%S')
  local log_message="[$timestamp] [$level] $message"
  
  # Log to console
  if [ "$level" = "ERROR" ]; then
    echo "$log_message" >&2
  else
    echo "$log_message"
  fi
  
  # Log to file
  echo "$log_message" >> "$LOG_FILE"
}

log_info() { log "INFO" "$1"; }
log_error() { log "ERROR" "$1"; }
log_debug() { log "DEBUG" "$1"; }

# Helper functions
validate_package_json() {
  local file=$1
  if ! jq empty "$file" 2>/dev/null; then
    log_error "Invalid JSON in $file"
    return 1
  fi
  return 0
}

setup_git() {
  log_debug "Setting up git configuration"
  git config --local user.email "$GIT_BOT_EMAIL"
  git config --local user.name "$GIT_BOT_NAME"
}

create_git_tag() {
  local package_name=$1
  local new_version=$2
  local tag="${package_name}@${new_version}"
  
  log_debug "Creating git tag: $tag"
  git tag -a "$tag" -m "Release $tag"
  git push origin "$tag"
}

get_package_info() {
  log_debug "Getting modified package.json files"
  local files
  files=$(git diff --name-only HEAD^ HEAD | grep "package.json" || true)
  
  if [ -z "$files" ]; then
    log_info "No package.json files were modified"
    return 0
  fi
  
  local packages=""
  local count=0
  
  while IFS= read -r file; do
    # Skip root package.json and invalid files
    [ "$file" = "package.json" ] && continue
    [ ! -f "$file" ] && continue
    
    log_debug "Processing package.json: $file"
    
    if ! validate_package_json "$file"; then
      continue
    fi
    
    # Extract package info in a single jq call
    local pkg_info
    pkg_info=$(jq -r '[.name, .version] | @tsv' "$file")
    local pkg_name pkg_version
    read -r pkg_name pkg_version <<< "$pkg_info"
    
    # Skip invalid packages
    [ -z "$pkg_name" ] || [ "$pkg_name" = "null" ] && continue
    [ -z "$pkg_version" ] || [ "$pkg_version" = "null" ] && continue
    
    local pkg_dir
    pkg_dir=$(dirname "$file")
    
    log_debug "Found valid package: $pkg_name@$pkg_version in $pkg_dir"
    packages+="${pkg_name}@${pkg_version}@${pkg_dir}\n"
    ((count++))
  done <<< "$files"
  
  if [ $count -gt 0 ]; then
    log_info "Found $count packages to process"
    echo -e "$packages"
  fi
}

publish_package() {
  local package_name=$1
  local new_version=$2
  local package_dir=$3
  
  if [ ! -d "$package_dir" ]; then
    log_error "Directory not found: $package_dir"
    return 1
  fi
  
  log_info "Publishing $package_name@$new_version from $package_dir"
  
  if ! (cd "$package_dir" && npm publish --dry-run --access public); then
    log_error "Failed to publish $package_name"
    return 1
  fi
  
  create_git_tag "$package_name" "$new_version"
  return 0
}

publish_packages() {
  local packages=$1
  local total_packages
  total_packages=$(echo -n "$packages" | grep -c '^' || true)
  
  if [ -z "$packages" ]; then
    log_info "No packages to publish"
    return 0
  fi
  
  setup_git
  local current=0
  
  log_info "Starting to publish $total_packages packages"
  
  while IFS= read -r package_info; do
    [ -z "$package_info" ] && continue
    ((current++))
    
    IFS='@' read -r package_name new_version package_dir <<< "$package_info"
    
    log_info "Processing package $current/$total_packages: $package_name"
    
    if ! publish_package "$package_name" "$new_version" "$package_dir"; then
      log_error "Failed to process $package_name, continuing with next package"
      continue
    fi
    
    # Wait between publishes if there are more packages
    if [ "$current" -lt "$total_packages" ]; then
      log_info "Waiting $WAIT_TIME seconds before next package..."
      sleep "$WAIT_TIME"
    fi
  done <<< "$packages"
  
  log_info "Completed publishing $current packages"
  log_info "Full logs available at: $LOG_FILE"
}