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

## Verification

After setup:

1. A new Ghostty window starts the intended Bash and renders the Starship prompt.
2. `git`, `terraform`, `pi`, and `herdr` are available in a new shell.
3. Chrome, Dropbox, 1Password, Slack, Zoom, and Tailscale are installed. Complete their interactive authentication only when the user is present.
4. Pi loads its non-secret configuration and MCP servers without extension errors.
5. The platform-specific verification checklist passes.
