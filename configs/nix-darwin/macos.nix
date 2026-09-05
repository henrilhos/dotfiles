{ ... }:
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

    dock = {
      # Automatically hide and show the dock.
      autohide = true;

      # Clear all pinned/default icons
      persistent-apps = [ ];

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
  };

  # Allow `sudo` to be satisfied with Touch ID instead of typing a password.
  security.pam.services.sudo_local.touchIdAuth = true;
}
