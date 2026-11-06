#!/usr/bin/env bash
# One-time setup for a fresh clone on macOS. Safe to run again.
# Usage: scripts/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n==> %s\n' "$1"; }

step "Command-line tools (Homebrew installs or upgrades them)"
brew install go golangci-lint pre-commit
go version
golangci-lint version

step "Git hooks"
pre-commit install

step "VS Code extensions"
if command -v code >/dev/null; then
  installed=$(code --list-extensions)
  for ext in $(grep -oE '"[a-z0-9-]+\.[a-z0-9-]+"' .vscode/extensions.json | tr -d '"'); do
    if grep -qix "$ext" <<<"$installed"; then
      echo "ok         $ext"
    else
      code --install-extension "$ext"
    fi
  done
else
  echo "! 'code' is not on PATH. In VS Code, run: Shell Command: Install 'code' command in PATH" >&2
fi

step "Run every check on every file"
pre-commit run --all-files
