#!/bin/bash
# ANSI escape sequences for text colors
BBlack="\033[1;30m"       # Black
BRed="\033[1;31m"         # Red
BGreen="\033[1;32m"       # Green
BYellow="\e[33;1m"      # Yellow
BBlue="\033[1;34m"        # Blue
BPurple="\033[1;35m"      # Purple
BCyan="\033[1;36m"        # Cyan
BWhite="\033[1;37m"       # White
RESET="\033[0m"           # Reset text formatting


# Function for displaying an error
display_error() {
  echo -e "${BRed}Error: $1${RESET}" >&2
  exit 1
}

# Function for displaying a success message
display_success() {
  echo -e "${BGreen}Success: $1${RESET}"
}

# Validate repository existence using GitHub API
echo -e "${BYellow}Validating repository...${RESET}"

repo_url="https://github.com/iqbal-hossain-vai/vai_test.git"

repo_name=$(basename "$repo_url" .git)

echo "your repository name is: $repo_name"

 n# Extract the GitHub username and repository name from the repository URL
regex='github.com/([^/]+)/([^/]+)'
if [[ $repo_url =~ $regex ]]; then
  github_username="${BASH_REMATCH[1]}"
else
  display_error "Invalid repository URL. Aborting validation."
fi

echo "your repository owner name is: $github_username"

# Make a GET request to the GitHub API to check repository existence
response=$(curl -sL -w "%{http_code}" "https://api.github.com/repos/$github_username/$repo_name")
response_code=$(tail -n1 <<<"$response")
if [[ "$response_code" == 200 ]]; then
  display_success "Repository exists."
else
  display_error "Repository does not exist. Aborting validation."
fi

# Parse the repository name from the GitHub link
repo_name=$(basename "$repo_url" .git)


# Set your GitHub access token
TOKEN="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"



# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

#branch_name=$(git symbolic-ref --short HEAD)


# Get the current branch name
branch_name=$(curl -s -H "Authorization: token $TOKEN" \
                 "https://api.github.com/repos/$github_username/$repo_name/branches" \
                 | jq -r '.[] | select(.name=="'$current_branch'") | .name')

# Extract the branch name from the response

echo "branch_name: $current_branch"

# Variables
# repository="your_repository_name"
# branch_name="your_branch_name"

# Revert the last pull request
pull_request_number=$(curl -s https://api.github.com/repos/$github_username/$repo_name/pulls?state=closed | jq -r '.[0].number')
echo "Reverting pull request #$pull_request_number..."
git fetch origin pull/$pull_request_number/head:$branch_name
git checkout $branch_name
reverted_commit=$(git log --pretty=format:'%H' -n 1)
git revert $reverted_commit -m 1 --no-edit
git push origin $branch_name

# Reopen the pull request
echo "Reopening pull request #$pull_request_number..."
curl -X PATCH -H "Authorization: token $TOKEN" -d '{"state": "open"}' "https://api.github.com/repos/$github_username/$repo_name/pulls/$pull_request_number"
