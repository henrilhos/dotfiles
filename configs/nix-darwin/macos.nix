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

      # Don't show recently used apps in the dock.
      show-recents = false;
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
