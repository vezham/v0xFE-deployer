#!/bin/bash

set -euo pipefail

# Function to check if jq command exists
check_dependencies() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed" >&2
    exit 1
  fi
}

# Function to get packages that need to be released
get_release_packages() {
  npx changeset status --json | \
    jq -r '.releases[] | select(.type != "none") | .name' | \
    grep . || true
}

# Function to create publish script
create_publish_script() {
  local packages="$1"
  local batch_size=10
  local delay_seconds=10
  local temp_file
  
  temp_file=$(mktemp)
  
  {
    echo "#!/bin/bash"
    echo "set -euo pipefail"
    echo
    echo "# Publish packages in batches"
    echo "echo 'Starting package publishing...'"
    echo
    
    # Create batches and add publish commands
    echo "$packages" | \
      xargs -n "$batch_size" | \
      while read -r batch; do
        echo "echo 'Publishing batch...'"
        echo "npx changeset publish --tag latest"
        echo "echo 'Waiting ${delay_seconds}s before next batch...'"
        echo "sleep $delay_seconds"
      done
    
    echo "echo 'All packages published successfully!'"
  } > "$temp_file"
  
  chmod +x "$temp_file"
  echo "$temp_file"
}

main() {
  check_dependencies

  packages=$(npx changeset status --json | jq -r '.releases[] | select(.type != "none") | .name' | tr '\n' ' ')
  echo $packages
  
  # Get packages to release
  # packages=$(get_release_packages)

  # echo $packages
  
  # if [ -n "$packages" ]; then
  #   # Create and set up publish script
  #   publish_script=$(create_publish_script "$packages")
  #   echo "::set-output name=publish::$publish_script"
  #   echo "::set-output name=packages::$packages"
  # else
  #   echo "::set-output name=publish::false"
  #   echo "::set-output name=packages::"
  # fi
}

main