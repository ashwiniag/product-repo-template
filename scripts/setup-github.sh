#!/usr/bin/env bash
# Applies the GitHub settings this repo expects. Safe to run again.
# Needs the GitHub CLI, logged in as a repo admin: gh auth login
# Usage: scripts/setup-github.sh [owner/repo]
set -euo pipefail

repo=${1:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}
visibility=$(gh repo view "$repo" --json visibility --jq .visibility)
echo "Configuring $repo ($visibility)"

warn() { echo "  ! $1" >&2; }

echo "- Merging: squash only, PR title as commit, delete merged branches"
gh repo edit "$repo" \
  --enable-squash-merge --squash-merge-commit-message pr-title-description \
  --enable-merge-commit=false --enable-rebase-merge=false \
  --delete-branch-on-merge

echo "- Dependabot alerts and security fixes"
gh api --silent -X PUT "repos/$repo/vulnerability-alerts"
gh api --silent -X PUT "repos/$repo/automated-security-fixes"

echo "- Private vulnerability reporting"
gh api --silent -X PUT "repos/$repo/private-vulnerability-reporting" ||
  warn "could not enable private vulnerability reporting"

echo "- Secret scanning and push protection"
gh repo edit "$repo" --enable-secret-scanning --enable-secret-scanning-push-protection ||
  warn "not available for this repo. It is free for public repos; private repos need GitHub Secret Protection."

echo "- Ruleset protecting the default branch"
ruleset_file="$(dirname "$0")/../.github/rulesets/main.json"
name=$(grep -m1 '"name"' "$ruleset_file" | cut -d'"' -f4)
id=$(gh api "repos/$repo/rulesets" --jq ".[] | select(.name == \"$name\") | .id")
if [[ -n "$id" ]]; then
  gh api --silent -X PUT "repos/$repo/rulesets/$id" --input "$ruleset_file" ||
    warn "could not update the ruleset"
else
  gh api --silent -X POST "repos/$repo/rulesets" --input "$ruleset_file" ||
    warn "could not create the ruleset. Rulesets on private repos need GitHub Pro or higher."
fi

echo "Done. Review: https://github.com/$repo/settings"
