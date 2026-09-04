{ pkgs, lib, ... }:
let
  yaml = pkgs.formats.yaml { };

  # Every PX project opens the same way: nvim beside a claude pane, then a
  # server window. Only the root and the server command differ.
  pxProject =
    {
      name,
      serverCommands,
      extraPanes ? [ null ],
      serverLayout ? "main-vertical",
    }:
    {
      inherit name;
      root = "~/Code/PX-Center/${name}";
      windows = [
        {
          editor = {
            panes = [
              {
                editor = [
                  "tmux set-window-option main-pane-width 65% && tmux select-layout main-vertical"
                  "nvim ."
                ];
              }
              { claude = [ "claude" ]; }
            ];
            layout = "main-vertical";
          };
        }
        {
          server = {
            panes = [ { server = serverCommands; } ] ++ extraPanes;
            layout = serverLayout;
          };
        }
      ];
    };

  npmServer =
    script:
    [ "export GITHUB_TOKEN=$(gh auth token) && mise x -- npm install && mise x -- npm run ${script}" ];

  projects = {
    Docs = {
      name = "Docs";
      root = "~/Docs";
      windows = [
        {
          editor.panes = [
            { claude = [ "claude --plugin-dir ~/Code/claude-obsidian" ]; }
          ];
        }
      ];
    };

    "PX/Axis" = pxProject {
      name = "Axis";
      serverCommands = npmServer "dev";
      extraPanes = [ { storybook = [ "mise x -- npm run storybook" ]; } ];
      serverLayout = "even-vertical";
    };

    "PX/Mobile" = pxProject {
      name = "Mobile";
      serverCommands = npmServer "start";
    };

    "PX/Painel" = pxProject {
      name = "Painel";
      serverCommands = npmServer "dev";
    };

    "PX/Torre" = pxProject {
      name = "Torre";
      serverCommands = [ "sail up -d && sail artisan migrate && lazydocker" ];
    };
  };
in
{
  xdg.configFile = lib.mapAttrs' (
    path: project:
    lib.nameValuePair "tmuxinator/${path}.yml" {
      source = yaml.generate "${baseNameOf path}.yml" project;
    }
  ) projects;
}
