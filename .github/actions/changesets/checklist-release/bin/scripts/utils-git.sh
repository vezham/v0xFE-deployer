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
  local pr_number
  
  log_debug "Creating git tag and release: $tag" "GIT"

  # Create annotated tag
  git tag -a "$tag" -m "ci: Release $tag"
  git push origin "$tag"

  # Get PR information
  pr_number=$(get_pr_info)
  local pr_link=""
  if [ -n "$pr_number" ]; then
    pr_link=$'\n\n'"- This release was created from PR [#${pr_number}](${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/pull/${pr_number})"
  fi

  # Generate release notes
  release_notes=$(cat <<EOF
## Release ${package_name} v${new_version}

### Changes
- Package published to npm
- For detailed changes, see the [changelog](./CHANGELOG.md) (if available)${pr_link}

### Installation
\`\`\`bash
npm install $tag
\`\`\`
EOF
)

  # Create GitHub release
  log_debug "Creating GitHub release for $tag" "GIT"
  
  if create_github_release "$tag" "$tag" "$release_notes"; then
    log_info "Successfully created release for $tag" "GIT"
  else
    log_warn "Failed to create GitHub release for $tag, but package was published successfully" "GIT"
  fi
  
  return 0
}

get_pr_info() {
  local pr_number
  
  # Get PR number from GitHub environment
  if [ -n "${GITHUB_EVENT_PATH:-}" ] && [ -f "$GITHUB_EVENT_PATH" ]; then
    pr_number=$(jq -r '.pull_request.number' "$GITHUB_EVENT_PATH")
    if [ "$pr_number" != "null" ]; then
      echo "$pr_number"
      return 0
    fi
  fi
  
  return 1
}

create_github_release() {
  local tag=$1
  local name=$2
  local body=$3
  
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
    return 1
  fi
  return 0
}