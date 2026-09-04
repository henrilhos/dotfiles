{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  colors = import ./themes/catppuccin-mocha.nix;

  # `--` so values that begin with a dash (the --background=... entries) are
  # taken as values rather than options.
  setColor = name: value: "set -g -- ${name} ${lib.escapeShellArg value}";
  colorInit = lib.concatStringsSep "\n" (lib.mapAttrsToList setColor colors);
in
{
  programs.fish = {
    enable = true;

    # Replaces fisher. fish_plugins and the ~30 vendored function files it used
    # to drop into the repo are gone; these are pinned in flake.lock instead.
    # Neither comes from pkgs.fishPlugins: fzf-fish is marked meta.broken there,
    # and catppuccin/fish is handled as colours in themes/catppuccin-mocha.nix.
    plugins = [
      {
        name = "fzf-fish";
        src = inputs.fzf-fish;
      }
      {
        name = "pisces";
        src = inputs.pisces;
      }
    ];

    shellAliases = {
      cd = "z";
      ls = "eza --icons=auto";
      cat = "bat";
    };

    shellAbbrs = {
      ":bd" = "exit";
      ":q" = "tmux kill-server";
      ":qa!" = "tmux kill-server";

      bi = "brew install";
      bic = "brew install --cask";
      bin = "brew info";
      binc = "brew info --cask";
      bl = "brew leaves";
      blr = "brew leaves --installed-on-request";
      blp = "brew leaves --installed-as-dependency";
      bs = "brew search";

      c = "clear";
      cl = "clear";
      claer = "clear";
      clera = "clear";

      d = "dev";
      dc = "docker compose";
      dcd = "docker compose down";
      dcdv = "docker compose down -v";
      dcr = "docker compose restart";
      dcu = "docker compose up -d";
      dps = "docker ps --format 'table {{.Names}}\t{{.Status}}'";

      e = "exit";

      ld = "lazydocker";
      lg = "lazygit";

      nb = "npm run build";
      nd = "npm run dev";
      ne = "nvim .env";
      nt = "npm run test";
      # Single-quoted through to fish so the substitution runs when the
      # abbreviation expands, not when it is defined.
      ni = "GITHUB_TOKEN=(gh auth token) npm install";

      o = "open .";

      rmr = "rm -rf";

      s = "sesh_start";
      "s." = "sesh connect .";
      sc = "sesh clone --cmdDir ~/c (pbpaste)";
      sf = "source ~/.config/fish/config.fish";
      sr = "sesh root";

      ta = "tmux attach";
      tk = "tmux kill-server";

      # Nix replacements for the old bootstrap workflow.
      nr = "~/.dotfiles/rebuild.sh";
      nu = "nix flake update --flake ~/.dotfiles";
      nq = "nvim ~/.dotfiles";
    };

    functions = {
      sail = {
        description = "Run Laravel Sail from the repo root or vendor/bin";
        body = ''
          if test -f sail
              sh sail $argv
          else
              sh vendor/bin/sail $argv
          end
        '';
      };

      queue_size = {
        description = "Tamanho de uma fila: queue_size <nome>";
        body = ''
          vendor/bin/sail artisan tinker --execute="echo Illuminate\Support\Facades\Queue::size('$argv[1]') . PHP_EOL;"
        '';
      };

      timeline = {
        description = "Lista os eventos da timeline do \$FREIGHT_ID";
        body = ''
          curl -s "http://localhost:8080/api/v2/company/offers/$FREIGHT_ID/timeline" \
              -H "Authorization: Bearer $TOKEN" \
            | jq '[.data.days[].events[] | {type, title, source_id, origin: .origin.value, person: .origin.person.name, has_details}]'
        '';
      };

      detail = {
        description = "Detalhe de um evento: detail <type> <source_id>";
        body = ''
          curl -s "http://localhost:8080/api/v2/company/offers/$FREIGHT_ID/timeline/$argv[1]/$argv[2]/details" \
              -H "Authorization: Bearer $TOKEN" | jq '.data.sections'
        '';
      };

      auto_venv = {
        description = "Activate .venv on entering a directory, deactivate on leaving";
        onVariable = "PWD";
        body = ''
          if test -f .venv/bin/activate.fish
              source .venv/bin/activate.fish
          else if set -q VIRTUAL_ENV
              deactivate 2>/dev/null
          end
        '';
      };
    };

    # Homebrew's shellenv, previously the first line of config.fish. In
    # loginShellInit so it runs once per login rather than on every subshell.
    loginShellInit = ''
      if test -x /opt/homebrew/bin/brew
          /opt/homebrew/bin/brew shellenv | source
      end
    '';

    interactiveShellInit = ''
      set -g fish_greeting

      # Setting the variable (rather than calling fish_vi_key_bindings) lets
      # fish's own reload handler run, so plugin bindings survive.
      #
      # The old config.fish set `fish_key_binding`, missing the trailing s, so
      # vi mode was never actually enabled. Fixed here.
      set -g fish_key_bindings fish_vi_key_bindings

      set -g pisces_only_insert_at_eol 1

      # Catppuccin Mocha, see themes/catppuccin-mocha.nix.
      ${colorInit}

      # Re-apply fzf.fish's bindings after the key-binding switch above.
      if functions -q fzf_configure_bindings
          fzf_configure_bindings
      end

      # Machine-local secrets, deliberately untracked.
      if test -f $HOME/.config/fish/secrets.fish
          source $HOME/.config/fish/secrets.fish
      end

      # OrbStack CLI integration, present only when OrbStack is installed.
      if test -f $HOME/.orbstack/shell/init2.fish
          source $HOME/.orbstack/shell/init2.fish
      end

      # mole is a Homebrew formula (nixpkgs' is marked broken).
      if command -q mole
          mole completion fish | source
      end
    '';
  };
}
