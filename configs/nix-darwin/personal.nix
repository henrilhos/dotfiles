# Applied only to hosts flagged `personal = true` in flake.nix: apps that
# stay off the work Mac. Lists merge with the shared ones in homebrew.nix.
{ ... }:
{
  homebrew.casks = [
    "datagrip"
    "discord"
    "prismlauncher"
    "raycast"
  ];

  # Disable Spotlight's default hotkeys (⌘Space / ⌘⌥Space) so Raycast can
  # take over ⌘Space instead. Set the Raycast side manually in its own
  # Settings > General — its hotkey preference uses a custom encoding
  # that isn't safe to write via `defaults write`.
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
    "64" = {
      enabled = false;
      value = {
        parameters = [
          32
          49
          1048576
        ];
        type = "standard";
      };
    };
    "65" = {
      enabled = false;
      value = {
        parameters = [
          32
          49
          1572864
        ];
        type = "standard";
      };
    };
  };
}
