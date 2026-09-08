{ config, ... }:
{
  system.defaults = {
    # Trackpad: tap to click instead of needing to press down.
    trackpad.Clicking = true;

    NSGlobalDomain = {
      # Scroll direction: disable "natural" (reversed) scrolling, i.e. scroll
      # like a traditional mouse wheel.
      "com.apple.swipescrolldirection" = false;

      # Appearance
      AppleInterfaceStyle = "Dark";

      # Units and locale: metric system, centimeters, Celsius, 24h clock.
      AppleMetricUnits = 1;
      AppleMeasurementUnits = "Centimeters";
      AppleTemperatureUnit = "Celsius";
      AppleICUForce24HourTime = true;

      # Disable autocorrect and automatic text substitution (dashes, quotes,
      # periods) — they do more harm than good for code/terminal use.
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;

      # Key repeat: disable press-and-hold (accent picker) in favor of
      # standard key repeat, then make repeat fast and start quickly.
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;

      # Finder: always show file extensions.
      AppleShowAllExtensions = true;
    };

    # Finder: show hidden (dotfile) files.
    finder.AppleShowAllFiles = true;

    # Screenshots go straight to the clipboard instead of saving a file.
    screencapture.target = "clipboard";

    dock = {
      # Automatically hide and show the dock.
      autohide = true;

      # Icon size, in pixels. The default is 64.
      tilesize = 24;
    };

    # Disable Spotlight's default hotkeys (⌘Space / ⌘⌥Space) so Raycast can
    # take over ⌘Space instead. Set the Raycast side manually in its own
    # Settings > General — its hotkey preference uses a custom encoding
    # that isn't safe to write via `defaults write`.
    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
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

    # Rectangle window snapping, bound to the Hyper key (⌘⌃⌥⇧, see
    # Karabiner) instead of Rectangle's own defaults. Action names and the
    # `defaults write ... -dict-add keyCode -float X modifierFlags -float Y`
    # format are documented at
    # https://github.com/rxhanson/Rectangle/blob/master/TerminalCommands.md
    # keyCode values are standard macOS virtual keycodes (H=4, J=38, K=40,
    # L=37, M=46); modifierFlags 1966080 = cmd+ctrl+opt+shift (Hyper).
    CustomUserPreferences."com.knollsoft.Rectangle" = {
      maximize = {
        keyCode = 46.0;
        modifierFlags = 1966080.0;
      };
      leftHalf = {
        keyCode = 4.0;
        modifierFlags = 1966080.0;
      };
      bottomHalf = {
        keyCode = 38.0;
        modifierFlags = 1966080.0;
      };
      topHalf = {
        keyCode = 40.0;
        modifierFlags = 1966080.0;
      };
      rightHalf = {
        keyCode = 37.0;
        modifierFlags = 1966080.0;
      };
    };
  };

  security.pam.services.sudo_local = {
    # Allow `sudo` to be satisfied with Touch ID instead of typing a password.
    touchIdAuth = true;

    # Without this, Touch ID for sudo silently doesn't work inside tmux
    # (or screen) — pam_tid checks it's talking to the same bootstrap
    # session as the login window, which tmux's detached server breaks.
    # pam_reattach fixes that by reattaching to the session first.
    reattach = true;
  };
}
