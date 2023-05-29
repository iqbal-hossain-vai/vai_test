#!/bin/bash

# Function for displaying an error
display_error() {
  echo -e "\033[1;31mError: $1\033[0m" >&2
  exit 1
}

# Function for displaying a success message
display_success() {
  echo -e "\033[1;32mSuccess: $1\033[0m"
}

# Validate repository existence
repo_path=$1
if [[ ! -d "$repo_path" ]]; then
  display_error "Repository directory '$repo_path' does not exist."
fi

# Change to the repository directory
cd "$repo_path" || display_error "Unable to change to repository directory."

# Revert the last pull
echo -e "\033[1;33mReverting the last pull...\033[0m"
git revert --no-edit HEAD

# Check if the revert succeeded
if [[ $? -eq 0 ]]; then
  display_success "Pull revert successful."
else
  display_error "Pull revert failed."
fi
