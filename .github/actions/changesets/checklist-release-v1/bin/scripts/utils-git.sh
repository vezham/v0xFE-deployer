#!/bin/bash

# wjdlz/NOTE: Source all required scripts by DIR
source "$(dirname "$0")/scripts/config.sh"
source "$(dirname "$0")/scripts/utils-log.sh"

# git | setup user
setup_git() {
  log_debug "Setting up git configuration"
  git config --local user.email "$GIT_BOT_EMAIL"
  git config --local user.name "$GIT_BOT_NAME"
}

# git | create tag
create_git_tag() {
  local package_name=$1
  local new_version=$2
  local tag="${package_name}@${new_version}"
  
  log_debug "Creating git tag: $tag"
  git tag -a "$tag" -m "Release $tag"
  git push origin "$tag"
}