# macOS defaults. Every setting here was previously a `defaults write` call in
# scripts/strap-after-setup.sh or scripts/setup/macos-security.sh.
#
# Dropped in the port:
#   - the two Safari WebKit2Java toggles (Java plugins no longer exist)
#   - com.apple.dashboard mcx-disabled (Dashboard is gone)
#   - networksetup -setdhcp "Ethernet" (no nix-darwin equivalent, and the
#     interface is DHCP by default anyway)
{ ... }:
{
  time.timeZone = "America/Sao_Paulo";

  networking.applicationFirewall.enable = true;

  system.keyboard.enableKeyMapping = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";

      # Metric everything.
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";

      # Key repeat over press-and-hold accent menus.
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;

      # Tab through every control, not just text fields.
      AppleKeyboardUIMode = 3;

      # No "natural" scrolling.
      "com.apple.swipescrolldirection" = false;

      # Autocorrect and smart substitution get in the way of writing code.
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      dashboard-in-overlay = true;
      expose-group-apps = true;
      minimize-to-application = true;
      persistent-apps = [ ]; # wipe the default macOS icons
      show-process-indicators = true;
      show-recents = false;
      showhidden = true;
    };

    finder = {
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXSortFoldersFirst = true;
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    menuExtraClock = {
      IsAnalog = false;
      # "EEE d MMM HH:mm"
      ShowAMPM = false;
      ShowDate = 1;
      ShowDayOfMonth = true;
      ShowDayOfWeek = true;
      Show24Hour = true;
      ShowSeconds = false;
    };

    loginwindow.LoginwindowText = "Found this computer? Please contact Henrique de Castilhos at hello@henrique.zip.";

    # Settings without a typed nix-darwin option.
    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleAccentColor = -1;
        AppleHighlightColor = "0.847059 0.847059 0.862745 Graphite";
      };
      "com.apple.TextEdit" = {
        RichText = 0; # plain text for new documents
        PlainTextEncoding = 4; # UTF-8 on read
        PlainTextEncodingForWrite = 4; # UTF-8 on write
      };
    };
  };
}
