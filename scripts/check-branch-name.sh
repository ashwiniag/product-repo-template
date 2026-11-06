#!/usr/bin/env bash
# Checks a branch name against type/short-name.
# Usage: check-branch-name.sh [branch]   (defaults to the branch being pushed)
set -euo pipefail

branch=${1:-${PRE_COMMIT_LOCAL_BRANCH:-$(git symbolic-ref --short HEAD 2>/dev/null || true)}}
branch=${branch#refs/heads/}

# Detached HEAD, or branches made by GitHub and Dependabot.
if [[ -z "$branch" || "$branch" =~ ^(dependabot|gh-readonly-queue)/ ]]; then
  exit 0
fi

types='build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test'
pattern="^($types)/[a-z0-9]+([.-][a-z0-9]+)*$"

if [[ ! "$branch" =~ $pattern ]] || (( ${#branch} > 60 )); then
  cat >&2 <<MSG
✗ Branch name "$branch" does not follow type/short-name.
  Types:   ${types//|/, }
  Rules:   lowercase letters, digits, hyphens and dots; 60 characters at most
  Example: feat/remote-image-scan  or  fix/123-null-digest
  Rename:  git branch -m <new-name>
MSG
  exit 1
fi
