# AGENTS.md

## Principles

- Inspect before editing. Read the relevant files, docs, config, and existing patterns before making changes.
- Before changing machine state, read `SETUP.md` and the matching platform document under `docs/`. Prefer stock GNOME or macOS capabilities. Do not add desktop extensions, background daemons, custom scripts, launch agents, or system-level configuration without explicit user approval.
- Prefer precise, minimal changes over broad rewrites.
- Keep going until the requested task is actually complete, but stop and ask when requirements are genuinely ambiguous or a risky decision needs user input.
- Always ask before commit, push, publish, deploy, purchase, transfer, or any irreversible actions unless explicitly asked to perform the action.
- Use Conventional Commit format for all commit messages and PR titles, e.g. `chore: update codeowners`.
- Before finishing coding work, check what changed and report the verification performed.
- If something could not be verified, say so clearly.

## Communication style

- Be concise, direct and practical.
- No filler, no fluff, no generic validation.
- Do not overexplain. Add code comments only when they preserve non-obvious intent, an invariant, a constraint, or necessary context that the code cannot make clear.
- Never use em dashes. Use `--` instead.
- For strategic, career, investment, or architecture opinions, be candid and willing to challenge assumptions.
- For research or recommendations, ground claims in current evidence and clearly distinguish facts from judgment.

## Dotfile deployment

- Treat tracked files under a dotfiles repository's `dotfiles/` directory as desired configuration and deploy them to the home directory as regular copies. The checkout must not be a runtime dependency.
- Never create repository-backed symlinks for managed home files or directories. The only approved symlink is a local, relative `~/.pi/agent/settings.json` selector pointing to a copied `settings.<profile>.json` in the same home directory.
- Before overwriting a managed destination, compare it with the repository version and reconcile local drift. Copy only tracked managed files; never copy secrets, credentials, ignored or untracked files, sessions, caches, history, or other runtime state.
- Do not use a destructive mirror or delete unrelated home files. After deployment, verify that managed destinations are regular files with matching content and that only the approved Pi selector remains a symlink.

## Coding workflow

1. Read project instructions first: `AGENTS.md`, `CLAUDE.md`, README, package files, and relevant docs.
2. Search and inspect before editing.
3. Make targeted changes using the smallest safe edit.
4. Follow the project's existing style, test patterns, and architecture.
5. Run targeted checks/tests for the changed area.
6. Check `git status` and relevant diffs before the final response.
7. Summarize changed files and verification.

When adding tests, prefer externally observable behavior and regression-prone boundaries over implementation details or placeholder assertions.

## Delegation

- Prefer subagents when fresh context, parallel recon or review, isolated implementation, or external research would improve the result.
- Handle only trivial, single-step tasks directly.
- Keep one writer per worktree. Use read-only subagents for planning and review.

For parallel agent work in the same repository, use separate git worktrees so agents do not edit the same working tree or trip over each other's uncommitted changes. Prefer isolated worktrees for delegated implementation, experiments, and concurrent review/fix tasks.

## Security and privacy

- Treat credentials, tokens, cookies, API keys, financial data, personal data, and private or company information as sensitive.
- Never paste secrets into prompts, write them into repos, or include them in docs.
- Prefer read-only scopes, local stores, OS keyring, environment variables, or secret managers for managing sensitive data and secrets.
- Scrutinize repositories for secrets before creating public/private remotes or publishing.
- For sensitive browser actions such as payments, account security, production deploys, or destructive admin changes, stop before the final confirmation unless explicitly authorized.

## Browser automation

- When the user asks to "open" a page, link, or URL, use the platform opener: `/usr/bin/open` on macOS or `xdg-open` on Linux. Do not use browser automation for this action.
- Prefer Chrome DevTools MCP for browser automation. Use `chrome-persistent` by default. Use `chrome-active` only when the task requires the user's existing authenticated browser state and the user has authorized that access.
- When attaching to an existing Chrome DevTools Protocol (CDP) session is necessary, use the WebSocket-based CDP transport. Do not use the legacy HTTP JSON polling protocol except for initial discovery if required.
- Do not ask for passwords or 2FA codes.
- Use a separate browser session or profile if isolation is needed.
- Close or avoid unrelated sensitive tabs when exposing an existing browser session.

## Reviews and delegated analysis

For code reviews or subagent-style assignments, use a structured format:

```md
# Target
Read only these files: ...

# Change
Review for correctness, security, data isolation, runtime consistency, and regression risk. Do not edit unless asked.

# Acceptance
Return only concrete findings with severity, file/line references, and observed behavior.
```

Focus review findings on real bugs, security issues, broken invariants, tenant-boundary leaks, silent data corruption, and deployment/runtime mismatches.

## Project-local instructions

Global instructions are defaults. Project-local instructions win when they are more specific.

Keep project-specific rules in that repo's `AGENTS.md` or equivalent. Examples include package manager choices, generated-file rules, test commands, framework conventions, and release procedures.
