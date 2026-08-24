# macOS desktop intent

Read [`../SETUP.md`](../SETUP.md) first.

## Desktop

- Prefer built-in macOS settings and application capabilities over custom launch agents, menu-bar replacements, window managers, or automation scripts.
- Use Ghostty as the terminal emulator and Chrome as the default browser when the user wants those defaults.
- Install a current stable external Bash and use it for interactive shells. Do not rely on macOS's bundled Bash 3.2.
- Use normal touchpad/trackpad scroll direction. Disable natural scrolling.
- Use the native workspace and window-management features unless the user explicitly approves an additional tool.

## Hungarian Windows ANSI keyboard layout

`dotfiles/Library/Keyboard Layouts/Magyar - Windows (ANSI).keylayout` is a
custom macOS input source generated from the official Windows Hungarian `KBDHU`
table for ANSI keyboards. The source project was created locally at
`~/hu-keylayout`; its generated `.keylayout` file is tracked here so the normal
home-directory overlay installs it at:

```text
~/Library/Keyboard Layouts/Magyar - Windows (ANSI).keylayout
```

After applying the overlay, log out and back in so macOS refreshes its input
source registry. Then open **System Settings -> Keyboard -> Text Input -> Edit**
and add **Magyar - Windows (ANSI)**. The layout puts `0` on the physical
backtick key, preserves Windows-style AltGr behavior through Option, and moves
`í` to Option+I because ANSI keyboards lack the ISO key left of Z.

## Verification

- A new Ghostty window starts the configured external Bash and Starship prompt.
- Required applications from [`../SETUP.md`](../SETUP.md) are installed.
- Touchpad/trackpad scrolling uses normal direction, not natural scrolling.
