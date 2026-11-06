# Machine setup intent

This repository describes the desired user environment. It does not contain provisioning or synchronization scripts. Before changing machine state, read [`dotfiles/AGENTS.md`](dotfiles/AGENTS.md), this file, and the platform document that applies.

## Operating model

- Detect the operating system and use its current supported installation method. Do not preserve obsolete package-manager commands solely because they worked on an older machine. Do not use Flatpak.
- Install current stable releases unless a project supplies a version requirement.
- Prefer stock GNOME and macOS capabilities. Do not add desktop extensions, replacement bars, tiling window managers, clipboard managers, background daemons, custom launch agents, or system-level tuning unless the user explicitly approves a documented need.
- Merge the tracked files under `dotfiles/` into the user's home directory. Do not restore removed legacy desktop configuration.
- Do not store credentials, tokens, browser profiles, OAuth state, session data, or machine-specific caches in this repository. The user completes sign-in, password, and 2FA steps.

## Apply dotfiles

Merge the tracked files under `dotfiles/` recursively into the user's home directory. On a new machine, it is a clean home-directory overlay. On an existing machine, do not use a destructive mirror or delete unrelated files. Copy configuration only; never copy credentials, browser profiles, OAuth state, sessions, caches, history, ignored files, untracked files, or other runtime state.

Use regular copies for every managed file. The repository records desired configuration; it is not a live runtime dependency. A Git pull, branch switch, checkout move, or checkout deletion must not immediately change or break the active environment. Do not create symlinks from managed home paths into the repository, and do not symlink managed directories.

Before replacing an existing managed destination, compare it with the repository version and reconcile any local drift. When converting a symlink to a regular copy, do not use a copy operation that follows the destination symlink and writes through to its target. Create the regular file separately and atomically replace the symlink. After applying the overlay, verify that every managed destination is a regular file, that its configuration matches the repository apart from local runtime preferences, and that no managed destination remains a symlink.

Treat `lastChangelogVersion` and `hideThinkingBlock` in Pi settings files as local runtime preferences. Ignore their differences during deployment and never commit them as configuration changes.

## MCP configuration and machine-local secrets

The shared MCP template is tracked at `dotfiles/.config/mcp/mcp.json`.
Pi's built-in MCP loader reads `~/.pi/agent/mcp.json`, not the shared template
path. Merge the template into that runtime file, preserving local-only servers,
credentials, and settings. The runtime file is machine-local: preserve it during
every overlay and never copy it back here. Do not load `pi-mcp-adapter`.

See [`docs/mcp.md`](docs/mcp.md) for migration, the 1Password and macOS Keychain
variants, and verification. Each runtime server must have a complete `command`
or `url` definition; partial adapter overrides must be merged before reloading.

## Local Git identity

`dotfiles/.gitconfig` includes `~/.gitconfig.local`. Keep the machine-local Git
email in that untracked file rather than in the repository:

```sh
git config --file "$HOME/.gitconfig.local" user.email "you@example.com"
chmod 600 "$HOME/.gitconfig.local"
```

## Pi configuration

Track the shared Pi configuration in `dotfiles/.pi/agent/settings.json` and copy
it to `~/.pi/agent/settings.json` as a regular file using the normal overlay.
Preserve local runtime preferences when reconciling settings.

Restart Pi after changing configuration. Authenticate providers locally with
`/login`; never copy `auth.json`, sessions, caches, or other runtime data.
Confirm the active routing with `/subagents-models` before relying on it.

## Pi skills

The custom `thermo-nuclear-code-quality-review` skill is tracked under
`dotfiles/.pi/agent/skills/` and copied by the normal overlay.

Install upstream skills with the [skills CLI](https://github.com/vercel-labs/skills)
rather than copying their contents or installer-created symlinks into this
repository. Review upstream instructions before installing:

```sh
npx skills add github/gh-stack -g -a pi --skill gh-stack
npx skills add cloudflare/skills -g -a pi --skill \
  agents-sdk cloudflare cloudflare-email-service cloudflare-one \
  cloudflare-one-migrations durable-objects sandbox-migrate-to-next \
  sandbox-next sandbox-stable turnstile-spin web-perf workers-best-practices wrangler
```

The `gh-stack` skill also requires `gh extension install github/gh-stack`.
The current skills CLI installs global Pi skills under `~/.agents/skills/`;
older installations may have links from `~/.pi/agent/skills/`. Leave these
installer-managed files outside the dotfiles overlay. After installation,
restart Pi and verify the skills are available with `/skill:<name>`.

## Common baseline

Install and configure these for the user:

- Sudo access for the user when needed to complete setup tasks.
- A current stable Bash. Use that Bash for interactive shells on both Linux and macOS. On macOS, do not rely on the system Bash 3.2. Add the resolved Bash path to `/etc/shells` and change the login shell only with user approval.
- Ghostty as the terminal emulator.
- Starship as the shell prompt.
- Git and Git LFS. Run `git lfs install` after installing Git LFS so repositories that use LFS can use the configured filters.
- Google Chrome, Dropbox, 1Password, Slack, Zoom, and Tailscale.
- Pi and Herdr, configured to use Pi without repository-local wrappers. Use the `ldx/pi-extensions` repository for the Pi setup.

## Required developer tools

On macOS, install developer tools and approved applications with Homebrew where
Homebrew provides a current supported package. Keep the exact package selection
in the platform setup notes rather than a repository Brewfile.

Install and keep current stable versions of:

- Node.js LTS, Go, Python with uv, Bun, and Rust.
- Docker and Docker Compose.
- Terraform, kubectl, Helm, and kubeconform.
- AWS CLI, Google Cloud CLI, and Azure CLI.
- Cloudflare Wrangler.
- PostgreSQL client tools and database clients required by active projects.
- SOPS and age.
- Neovim configured with LazyVim, with `vim` invoking Neovim rather than regular Vim, GitHub CLI, 1Password CLI, jq, gawk, direnv, ripgrep, fd, fzf, ShellCheck, shfmt, Gitleaks, pre-commit, and Worktrunk.
- Sessiongrep, built from source with Cargo. Configure its local Pi MCP server so agents can search session history.

Respect project-pinned versions where present. Install other developer tools when a project or task requires them.

## Verification and completion

Do not mark setup complete until every applicable automated check and every available manual check below passes. Report each unavailable, hardware-dependent, authentication-dependent, or user-interaction check separately rather than treating it as complete.

After setup:

1. A new Ghostty window starts the intended Bash and renders the Starship prompt.
2. `git`, `terraform`, `pi`, and `herdr` are available in a new shell.
3. Chrome, Dropbox, 1Password, Slack, Zoom, and Tailscale are installed. Verify Chrome is the default HTTP and HTTPS handler. Complete their interactive authentication only when the user is present.
4. Pi loads its non-secret configuration and configured MCP servers without extension errors. Report lazy MCP servers that were not connected as unverified, not passing.
5. `sessiongrep doctor` reports local Pi sessions and `sessiongrep search` returns results.
6. The platform-specific verification checklist passes.
7. Completion report lists passed checks, failed checks, and checks that still require user interaction or hardware verification.
