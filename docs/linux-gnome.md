# Linux desktop intent

Read [`../SETUP.md`](../SETUP.md) first.

## Desktop

- Use stock GNOME on Wayland.
- Use the Activities Overview for window and workspace switching.
- When a connected mouse has a middle or clickable scroll-wheel button, map that button globally to the Activities Overview. This intentionally replaces the usual middle-click primary-selection paste action. Stock GNOME on Wayland does not provide global mouse-button shortcuts, so first prefer a device's persistent onboard mapping to emit the configured **Show the activities overview** shortcut. If the hardware cannot do that, obtain explicit approval for a Wayland-compatible GNOME Shell extension or input remapper before installing it, then record its exact source and version and update the approved-extension inventory below when applicable. Do not use X11-only `xbindkeys` or `xinput` recipes, and do not treat an extension that works only over the top bar as satisfying this requirement.
- Use normal touchpad/trackpad scroll direction. Disable natural scrolling.
- Stock GNOME couples the vertical three-finger Overview direction to natural scrolling: with normal scrolling, three fingers down opens the Overview. If three fingers up must open the Overview while normal scrolling remains enabled, obtain explicit approval for a compatible gesture extension before installing it; record its exact source and version.
- Use the system's native notification, lock-screen, display, network, power, and clipboard behavior.
- Set Ghostty as the preferred terminal and Chrome as the default browser when supported by the desktop settings.
- When Ghostty is installed from a standalone upstream binary, install the matching release's official `images/gnome` assets in `~/.local/share/icons/hicolor/` under the `com.mitchellh.ghostty` icon ID. Add `Icon=com.mitchellh.ghostty` to `~/.local/share/applications/com.mitchellh.ghostty.desktop`, then refresh the local GTK icon cache and desktop database. Do not use a generic terminal icon or third-party artwork.
- Configure the keyboard so Caps Lock sends Escape.
- On PC keyboards, configure both Alt keys as AltGr for easy access to characters such as `[]`, `{}`, and `;`.
- If a supported fingerprint reader is detected, configure fingerprint authentication using the platform-supported stack. On Debian, install `fprintd`, its required `libfprint` package, and `libpam-fprintd`; enable the `fprintd` PAM profile with `pam-auth-update --enable fprintd` before enrollment. Enroll fingerprints only in an interactive user session, retain password fallback, and never make fingerprint authentication the sole recovery method.

## Debian notes

- If `sudo` cannot authenticate in the current agent session but graphical authorization works, agents may use `pkexec` for already user-approved privileged setup. Do not request or handle passwords or 2FA codes. Then add the user to the required groups. Group membership changes require a new login session.
- If Ghostty is not available from the current Debian repositories, use a current AppImage or other maintained upstream/community binary rather than Flatpak.
- Dropbox's Debian package may add an apt source whose signing key is rejected by current Debian policy. If that breaks `apt update`, disable the Dropbox apt source after installing the desktop package.
- After installing Docker, add the user to the `docker` group and start a new login session before expecting unprivileged `docker` commands to work.
- Approved exception for this environment: install [Touchpad Gesture Customization version 23](https://extensions.gnome.org/extension/7850/touchpad-gesture-customization/) from the GNOME Extensions catalog. It supports GNOME 45--48 and is the only enabled extension. Keep normal scrolling, set three-finger vertical swipe to Overview navigation with its default Overview direction enabled, and disable its other swipe and pinch actions. Log out and in after installation so GNOME Shell discovers it, then run `gnome-extensions enable touchpad-gesture-customization@coooolapps.com` and require `gnome-extensions info` to report `Enabled: Yes` and `State: ACTIVE`. Revalidate the gesture after every GNOME Shell update.

## Verification and completion

Do not mark Linux desktop setup complete until every applicable item below passes. Record hardware-dependent and interactive checks separately when they cannot be performed in the current session.

- The login session is GNOME on Wayland.
- Chrome is the default handler for both HTTP and HTTPS URLs. Verify with `xdg-mime query default x-scheme-handler/http` and `xdg-mime query default x-scheme-handler/https`.
- Ghostty is installed, displays its official icon in Activities Overview, and a new window starts the intended Bash and Starship prompt.
- `org.gnome.desktop.peripherals.touchpad natural-scroll` is `false`.
- With no gesture extension, three fingers down opens the Activities Overview when natural scrolling is disabled. Confirm this manually after a fresh GNOME login.
- When the approved Touchpad Gesture Customization version 23 is configured to preserve normal scrolling and map three fingers up to the Overview, verify that exact behavior manually after a fresh GNOME login. Confirm `gnome-extensions info touchpad-gesture-customization@coooolapps.com` reports version 23, `Enabled: Yes`, and `State: ACTIVE`, and confirm it is the only enabled extension. If it fails, leave setup incomplete and record the GNOME Shell version and relevant `overview` or gesture errors.
- GNOME's Activities Overview can switch windows and workspaces. Confirm this manually.
- With a compatible mouse connected, pressing its middle/wheel-click button anywhere opens the Activities Overview. Confirm this manually in both a native Wayland application and an Xwayland application. If no approved Wayland-compatible mapping is available, leave setup incomplete and record the mouse model, GNOME version, and missing mechanism.
- `org.gnome.desktop.input-sources xkb-options` includes `caps:escape`, `lv3:lalt_switch`, and `lv3:ralt_switch`; then confirm the keys work in an application.
- When a supported fingerprint reader is present, `fprintd`, `libfprint`, and `libpam-fprintd` are installed; `common-auth` has a `pam_fprintd.so` entry before `pam_unix.so`; the user is enrolled; fingerprint authentication succeeds; and password authentication remains available. Enrollment and authentication must be confirmed interactively.
