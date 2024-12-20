#!/usr/bin/env bash

# Script to update configurations with Git and Nix flakes.
# Ensure colors are updated first as neovim depends on them.

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Catch errors in pipelines

# Function to update, commit, and push a flake with nix flake update
git_update_push() {
  local dir=$1
  local message=$2
  
  echo "Updating $dir..."
  cd "$dir"

  # Run nix flake update to update dependencies
  sudo nix flake update

  # Stage changes, commit, and push
  git add .
  git commit -m "$message" || echo "No changes to commit in $dir."
  git push

  # Return to original directory
  cd - >/dev/null
}

# Main function
echo "Starting update script..."

targets=("$@")

declare -A dependencies=(
  [colors]=0
  [neovim-config]=1
  [main]=2
)

if [[ " ${targets[@]} " =~ " all " ]]; then
  targets=(colors neovim-config main)
else
  # Ensure proper dependency order
  IFS=$'\n' targets=($(for t in "${targets[@]}"; do echo "$t"; done | sort -k1,1 -n))
fi

# Process updates in order
for target in "${targets[@]}"; do
  case $target in
    colors)
      git_update_push "/etc/nixos/colors" "Update colors flake"
      ;;
    neovim-config)
      git_update_push "/etc/nixos/neovim-config" "Update neovim-config flake"
      ;;
    main)
      git_update_push "/etc/nixos/main" "Update main flake"
      ;;
    *)
      echo "Unknown target: $target"
      exit 1
      ;;
  esac
done

echo "All updates completed successfully."
