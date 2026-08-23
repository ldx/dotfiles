# Linux desktop intent

Read [`../SETUP.md`](../SETUP.md) first.

## Desktop

- Use stock GNOME on Wayland.
- Enable the native three-finger horizontal touchpad gesture for workspace switching when the hardware supports it.
- Use the Activities Overview for window and workspace switching.
- Use normal touchpad/trackpad scroll direction. Disable natural scrolling.
- Use the system's native notification, lock-screen, display, network, power, and clipboard behavior.
- Set Ghostty as the preferred terminal and Chrome as the default browser when supported by the desktop settings.
- Configure the keyboard so Caps Lock sends Escape.
- On PC keyboards, configure both Alt keys as AltGr for easy access to characters such as `[]`, `{}`, and `;`.
- If a supported fingerprint reader is detected, configure fingerprint authentication using the platform-supported stack. Enroll fingerprints only in an interactive user session, retain password fallback, and never make fingerprint authentication the sole recovery method.

## Debian notes

- If sudo is not yet usable in the current session but graphical authorization works, use `pkexec` for privileged setup and then add the user to the required groups. Group membership changes require a new login session.
- If Ghostty is not available from the current Debian repositories, use a current AppImage or other maintained upstream/community binary rather than Flatpak.
- Dropbox's Debian package may add an apt source whose signing key is rejected by current Debian policy. If that breaks `apt update`, disable the Dropbox apt source after installing the desktop package.
- After installing Docker, add the user to the `docker` group and start a new login session before expecting unprivileged `docker` commands to work.

## Verification

- The login session is GNOME on Wayland.
- Three-finger horizontal swipes change workspaces when the touchpad supports them.
- Touchpad/trackpad scrolling uses normal direction, not natural scrolling.
- GNOME's Activities Overview opens and can switch windows and workspaces.
- Caps Lock sends Escape, and both Alt keys act as AltGr on PC keyboards.
- When a supported fingerprint reader is present, the enrolled user can authenticate with it while password authentication remains available.
