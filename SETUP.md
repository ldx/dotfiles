# Machine setup intent

This repository describes the desired user environment. It does not contain provisioning or synchronization scripts. Before changing machine state, read [`dotfiles/AGENTS.md`](dotfiles/AGENTS.md), this file, and the platform document that applies.

## Operating model

- Detect the operating system and use its current supported installation method. Do not preserve obsolete package-manager commands solely because they worked on an older machine. Do not use Flatpak.
- Install current stable releases unless a project supplies a version requirement.
- Prefer stock GNOME and macOS capabilities. Do not add desktop extensions, replacement bars, tiling window managers, clipboard managers, background daemons, custom launch agents, or system-level tuning unless the user explicitly approves a documented need.
- Merge the contents of `dotfiles/` into the user's home directory. Do not restore removed legacy desktop configuration.
- Do not store credentials, tokens, browser profiles, OAuth state, session data, or machine-specific caches in this repository. The user completes sign-in, password, and 2FA steps.

## Apply dotfiles

Merge `dotfiles/` recursively into the user's home directory. On a new machine, it is a clean home-directory overlay. On an existing machine, do not use a destructive mirror or delete unrelated files. Copy configuration only; never copy credentials, browser profiles, OAuth state, sessions, caches, history, or other runtime state.

## Select a Pi subscription profile

`dotfiles/.pi/agent/settings.json` is the canonical Codex-only profile. The
following tracked alternatives are templates and are not loaded by Pi until
copied over `~/.pi/agent/settings.json`:

- `settings.github-copilot-codex.json` -- select when both GitHub Copilot and
  ChatGPT Codex subscriptions are available.
- `settings.codex-opencode-go.json` -- select when both ChatGPT Codex and
  OpenCode Go subscriptions are available.

Applying the dotfiles means recursively copying the contents of `dotfiles/`
into the user's home directory. It is a home-directory overlay, not a Git
merge: `dotfiles/.pi/agent/*` becomes `~/.pi/agent/*`, and unrelated home files
are not deleted. After that overlay is applied, copy the selected local template
to the active Pi settings path, for example:

```sh
cp ~/.pi/agent/settings.codex-opencode-go.json ~/.pi/agent/settings.json
```

Restart Pi after changing profiles. Authenticate each selected provider locally
with `/login`; never copy `auth.json`, sessions, caches, or other runtime data.
Confirm the active routing with `/subagents-models` before relying on it.

## Common baseline

Install and configure these for the user:

- Sudo access for the user when needed to complete setup tasks.
- A current stable Bash. Use that Bash for interactive shells on both Linux and macOS. On macOS, do not rely on the system Bash 3.2. Add the resolved Bash path to `/etc/shells` and change the login shell only with user approval.
- Ghostty as the terminal emulator.
- Starship as the shell prompt.
- Git.
- Google Chrome, Dropbox, 1Password, Slack, Zoom, and Tailscale.
- Pi and Herdr, configured to use Pi without repository-local wrappers. Use the `ldx/pi-extensions` repository for the Pi setup.

## Required developer tools

Install and keep current stable versions of:

- Node.js LTS, Go, Python with uv, and Bun.
- Docker and Docker Compose.
- Terraform, kubectl, Helm, and kubeconform.
- AWS CLI, Google Cloud CLI, and Azure CLI.
- Cloudflare Wrangler.
- PostgreSQL client tools and database clients required by active projects.
- SOPS and age.
- Neovim configured with LazyVim, with `vim` invoking Neovim rather than regular Vim, GitHub CLI, 1Password CLI, jq, gawk, direnv, ripgrep, fd, and fzf.

Respect project-pinned versions where present. Install other developer tools when a project or task requires them.

## Verification and completion

Do not mark setup complete until every applicable automated check and every available manual check below passes. Report each unavailable, hardware-dependent, authentication-dependent, or user-interaction check separately rather than treating it as complete.

After setup:

1. A new Ghostty window starts the intended Bash and renders the Starship prompt.
2. `git`, `terraform`, `pi`, and `herdr` are available in a new shell.
3. Chrome, Dropbox, 1Password, Slack, Zoom, and Tailscale are installed. Verify Chrome is the default HTTP and HTTPS handler. Complete their interactive authentication only when the user is present.
4. Pi loads its non-secret configuration and configured MCP servers without extension errors. Report lazy MCP servers that were not connected as unverified, not passing.
5. The platform-specific verification checklist passes.
6. Completion report lists passed checks, failed checks, and checks that still require user interaction or hardware verification.
