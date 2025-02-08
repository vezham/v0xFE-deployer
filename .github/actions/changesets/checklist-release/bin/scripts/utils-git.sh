#!/bin/bash

# git | setup user
setup_git() {
  log_debug "Setting up git configuration" "GIT"
  git config --local user.email "$GIT_BOT_EMAIL"
  git config --local user.name "$GIT_BOT_NAME"
}

# git | create tag
create_git_tag() {
  local package_name=$1
  local new_version=$2
  local tag="${package_name}@${new_version}"
  
  log_debug "Creating git tag: $tag" "GIT"
  git tag -a "$tag" -m "ci: Release $tag"
  git push origin "$tag"
}