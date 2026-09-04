{ ... }:
let
  # right_command + hjkl -> arrow keys
  arrowKey = from: to: {
    type = "basic";
    from = {
      key_code = from;
      modifiers = {
        mandatory = [ "right_command" ];
        optional = [ "any" ];
      };
    };
    to = [ { key_code = to; } ];
  };

  profile = {
    name = "Default profile";
    selected = true;

    complex_modifications.rules = [
      {
        description = "Change right_command+hjkl to arrow keys";
        manipulators = [
          (arrowKey "h" "left_arrow")
          (arrowKey "j" "down_arrow")
          (arrowKey "k" "up_arrow")
          (arrowKey "l" "right_arrow")
        ];
      }
      {
        manipulators = [
          {
            description = "Change caps_lock to command+control+option+shift.";
            type = "basic";
            from = {
              key_code = "caps_lock";
              modifiers.optional = [ "any" ];
            };
            to = [
              {
                key_code = "left_shift";
                modifiers = [
                  "left_command"
                  "left_control"
                  "left_option"
                ];
              }
            ];
          }
        ];
      }
    ];

    devices = [
      {
        identifiers.is_keyboard = true;
        simple_modifications = [
          {
            from.key_code = "grave_accent_and_tilde";
            to = [ { key_code = "left_shift"; } ];
          }
          {
            from.key_code = "non_us_backslash";
            to = [ { key_code = "grave_accent_and_tilde"; } ];
          }
        ];
      }
      {
        # External keyboard: shut off the built-in one while it is connected.
        disable_built_in_keyboard_if_exists = true;
        identifiers = {
          is_keyboard = true;
          vendor_id = 64562;
          product_id = 647;
        };
      }
    ];

    virtual_hid_keyboard.keyboard_type_v2 = "ansi";
  };
in
{
  # Karabiner-Elements rewrites this file when you touch its UI, so treating it
  # as generated means UI edits get reverted on the next switch. That is the
  # intended trade: the rules live here.
  xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
    profiles = [ profile ];
  };
}
