{ ... }:
{
  # mise still owns the per-project language runtimes; nixpkgs owns the tools
  # around them. The two do not overlap.
  programs.mise = {
    enable = true;
    enableFishIntegration = true;

    globalConfig = {
      tools = {
        java = "openjdk-17";
        node = "24";
      };

      settings = {
        # Read .node-version and friends, but only for node.
        idiomatic_version_file_enable_tools = [ "node" ];
      };
    };
  };
}
