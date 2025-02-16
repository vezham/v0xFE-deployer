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
  local release_notes
  local repo_path
  
  log_debug "Creating git tag and release: $tag" "GIT"

  # Create annotated tag
  git tag -a "$tag" -m "ci: Release $tag"
  git push origin "$tag"

  # Generate release notes
  release_notes=$(cat <<EOF
## ${package_name} v${new_version}

### Changes
- Package published to npm
- For detailed changes, see the [changelog](./CHANGELOG.md) (if available)

### Installation
\`\`\`bash
npm install $tag
\`\`\`
EOF
)

  # Create GitHub release
  log_debug "Creating GitHub release for $tag" "GIT"
  repo_path=$(get_repo_info)
  
  if create_github_release "$tag" "Release $tag" "$release_notes" "$repo_path"; then
    log_info "Successfully created release for $tag" "GIT"
  else
    log_warn "Failed to create GitHub release for $tag, but package was published successfully" "GIT"
  fi
  
  return 0
}

# git | get repo
get_repo_info() {
  local repo_url=$(git config --get remote.origin.url)
  log_debug "repo_url: $repo_url" "GIT"

  echo "$repo_url" | sed -E 's/.*github.com[:/]([^/]+\/[^/]+)(\.git)?$/\1/'
}

create_github_release() {
  local tag=$1
  local name=$2
  local body=$3
  local repo_path=$4
  
  # Check if GITHUB_TOKEN is available
  if [ -z "$GITHUB_TOKEN" ]; then
    log_error "GITHUB_TOKEN is not set. Skipping GitHub release creation." "GIT"
    return 1
  fi

  # Create release using gh CLI
  if ! echo "$body" | gh release create "$tag" \
    --title "$name" \
    --notes-file - \
    --verify-tag; then
    log_error "Failed to create GitHub release for $tag" "GIT"
    return 1
  fi
  log_info "Successfully created release for $tag" "GIT"
  return 0

#   curl -s -X POST \
#     -H "Authorization: token $GITHUB_TOKEN" \
#     -H "Accept: application/vnd.github.v3+json" \
#     "${GITHUB_API}/repos/${repo_path}/releases" \
#     -d @- <<EOF
# {
#   "tag_name": "${tag}",
#   "name": "${name}",
#   "body": $(echo "$body" | jq -R -s .),
#   "draft": false,
#   "prerelease": false
# }
# EOF
}