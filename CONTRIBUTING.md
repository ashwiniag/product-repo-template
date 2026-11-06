# Contributing

## One-time setup

```bash
scripts/setup.sh
```

This installs Go, golangci-lint and pre-commit with Homebrew, installs the git hooks and the recommended VS Code extensions, then runs every check once. It is safe to run again whenever the setup changes.

## Where settings live

| File | What it controls | Who reads it |
|---|---|---|
| `.editorconfig` | Indentation, line endings, final newline | Every editor |
| `.vscode/settings.json` | Format on save, formatter for each language, Go lint on save | VS Code |
| `.vscode/extensions.json` | Recommended extensions | VS Code |
| `.golangci.yml` | Go linters and formatters (gofumpt, goimports) | VS Code, pre-commit, CI |
| `.yamllint.yaml` | YAML style | pre-commit, CI |
| `.pre-commit-config.yaml` | Every check, with pinned versions | Your machine, CI |

The editor shows problems while you type. pre-commit is the gate: if `pre-commit run --all-files` passes locally, CI's checks job passes too.

## Workflow

1. Branch from an up-to-date `main`: `git switch main && git pull && git switch -c feat/short-name`
2. Commit in small steps. Hooks check every commit.
3. Push and open a PR. CI must pass.
4. Squash-merge. The PR title becomes the single commit on `main`.

`main` is protected: no direct pushes, no force pushes, and every change goes through a PR with passing checks.

## Branch names

`type/short-name`, lowercase, with hyphens. Add an issue number if there is one.

```text
feat/remote-image-scan
fix/123-null-digest
docs/install-guide
```

## Commit messages and PR titles

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/): `type(scope): summary`. Keep the header to 72 characters, use the imperative mood, and leave off the final period.

| Type | Use for |
|---|---|
| `feat` | A new capability for users |
| `fix` | A bug fix |
| `docs` | Documentation only |
| `test` | Adding or fixing tests |
| `refactor` | A code change that neither fixes a bug nor adds a feature |
| `perf` | A performance improvement |
| `build` | Build system or dependencies |
| `ci` | CI configuration |
| `chore` | Maintenance that fits none of the above |
| `style` | Formatting only |
| `revert` | Reverting an earlier commit |

Add `!` for a breaking change, and explain it in the body: `feat(api)!: rename scan endpoint`.

## Secrets

Never commit credentials, tokens, keys, kubeconfigs or `.env` files. Three layers catch mistakes: `.gitignore`, the gitleaks hook on every commit, and GitHub push protection on the server.

If a secret does get committed, **revoke and rotate it first**. Removing it from history does not make it safe, because it may already have been copied.

## What runs where

| Check | On commit | On push | In CI |
|---|---|---|---|
| Secrets (gitleaks) | Staged changes | | Full history |
| Private keys, large files, merge conflicts | Yes | | Yes |
| Go lint and format (golangci-lint) | Yes | | Yes |
| JSON and YAML syntax, yamllint | Yes | | Yes |
| Workflow lint and security (actionlint, zizmor) | Yes | | Yes |
| Whitespace and line endings | Yes (auto-fixed) | | Yes |
| Commit message format | Yes | | PR title |
| Branch name | | Yes | Yes |
| No commits to `main` | Yes | | Ruleset |
