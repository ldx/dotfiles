# macOS desktop intent

Read [`../SETUP.md`](../SETUP.md) first.

## Desktop

- Prefer built-in macOS settings and application capabilities over custom launch agents, menu-bar replacements, window managers, or automation scripts.
- Use Ghostty as the terminal emulator and Chrome as the default browser when the user wants those defaults.
- Install a current stable external Bash and use it for interactive shells. Do not rely on macOS's bundled Bash 3.2.
- Use normal touchpad/trackpad scroll direction. Disable natural scrolling.
- When a connected mouse has a middle or clickable scroll-wheel button, map that button to Mission Control using **System Settings -> Desktop & Dock -> Mission Control -> Shortcuts**. Select the middle/wheel-click entry in the Mission Control mouse-shortcut menu, commonly shown as **Mouse Button 3**. Availability and naming depend on the connected mouse. If macOS does not expose the button there, report the hardware limitation; do not install a remapper or background utility without explicit approval.
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
and add and select **Magyar - Windows (ANSI)**. The layout puts `0` on the
physical backtick key, preserves Windows-style AltGr behavior through Option,
and moves `í` to Option+I because ANSI keyboards lack the ISO key left of Z.

Remove **U.S.** so macOS cannot switch typing back to it. If macOS requires an
Apple-provided fallback before it will remove U.S., add the built-in
**Hungarian** layout first; every remaining keyboard source is then Hungarian.
Turn off automatic switching to a document's input source, disable both input
source shortcuts under **Keyboard Shortcuts -> Input Sources**, and set the
Fn/Globe key action to **Do Nothing**. Character Viewer may remain enabled
because it is not a keyboard layout.

## Verification

- A new Ghostty window starts the configured external Bash and Starship prompt.
- Required applications from [`../SETUP.md`](../SETUP.md) are installed.
- Touchpad/trackpad scrolling uses normal direction, not natural scrolling.
- With a compatible mouse connected, pressing its middle/wheel-click button opens Mission Control. Confirm this manually because the shortcut control is hardware-dependent.
- `defaults read com.apple.HIToolbox AppleEnabledInputSources` lists no U.S.
  keyboard source; all listed keyboard layouts are Hungarian.
- **Magyar - Windows (ANSI)** remains selected after a fresh login, input-source
  keyboard shortcuts are disabled, and Fn/Globe does not change input source.
- After a restart, verify the FileVault preboot screen separately uses its
  built-in Hungarian layout; do not infer this from the logged-in user session.
