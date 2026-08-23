# macOS desktop intent

Read [`../SETUP.md`](../SETUP.md) first.

## Desktop

- Prefer built-in macOS settings and application capabilities over custom launch agents, menu-bar replacements, window managers, or automation scripts.
- Use Ghostty as the terminal emulator and Chrome as the default browser when the user wants those defaults.
- Install a current stable external Bash and use it for interactive shells. Do not rely on macOS's bundled Bash 3.2.
- Use the native workspace and window-management features unless the user explicitly approves an additional tool.

## Verification

- A new Ghostty window starts the configured external Bash and Starship prompt.
- Required applications from [`../SETUP.md`](../SETUP.md) are installed.
