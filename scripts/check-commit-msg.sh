#!/usr/bin/env bash
# Checks a commit message or PR title against Conventional Commits.
# Usage: check-commit-msg.sh <file-with-message>   (git commit-msg hook)
#        check-commit-msg.sh --text "feat(scan): add sbom export"
set -euo pipefail

if [[ "${1:-}" == "--text" ]]; then
  header=${2:-}
else
  # First line that is not a comment. Git strips comments after this hook runs.
  header=$(grep -v '^#' "${1:?message file required}" | head -n 1 || true)
fi

# Messages git writes itself.
if [[ "$header" =~ ^(Merge\ |Revert\ \"|fixup!\ |squash!\ |amend!\ ) ]]; then
  exit 0
fi

types='build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test'
pattern="^($types)(\([a-z0-9][a-z0-9-]*\))?!?: [^ ].*[^.]$"

fail() {
  cat >&2 <<MSG
✗ $1
  Got:      $header
  Expected: type(scope): summary
  Types:    ${types//|/, }
  Example:  feat(scanner): scan remote images without pulling
MSG
  exit 1
}

[[ "$header" =~ $pattern ]] || fail "not a Conventional Commit header (lowercase type, colon, space, no trailing period)"
(( ${#header} <= 72 )) || fail "header is ${#header} characters; keep it to 72 or fewer"
