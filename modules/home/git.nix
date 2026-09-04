{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    # Commit signing goes through 1Password's SSH agent, not GPG.
    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGIa977/ftf7GB5CJq0K/nP9aDgdKOPJeHMwjY0GHYN";
      signByDefault = true;
      signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    ignores = [
      "**/.claude/settings.local.json"
    ];

    settings = {
      user = {
        name = "Henrique de Castilhos";
        # Deliberately the personal address, not whatever work email happens to
        # be set on a given machine — this repo is public.
        email = "hello@henrique.zip";
      };

      alias = {
        aa = "add --all";
        br = "branch";
        bra = "branch --all";
        brd = "branch -d";
        brD = "branch -D";
        brm = "branch -m";
        ci = "commit";
        cia = "commit --amend";
        cis = "commit --squash";
        co = "checkout";
        cob = "checkout -b";
        cod = "checkout develop";
        com = "checkout main";
        f = "fetch";
        first = "rev-list --max-parents=0 HEAD";
        l = "pull";
        last = "log --graph --show-signature --pretty=short --max-count=10";
        logd = "log --pretty='format:- %s (%h)' --reverse develop..HEAD";
        logdpr = "log --pretty='format:- %s (%h)%n  %b' --reverse develop..HEAD --grep 'pull request'";
        logm = "log --pretty='format:- %s (%h)' --reverse main..HEAD";
        logmpr = "log --pretty='format:- %s (%h)%n  %b' --reverse main..HEAD --grep 'pull request'";
        p = "push";
        pf = "push --force-with-lease";
        pt = "push --tags";
        pso = "push --set-upstream origin";
        ra = "remote add";
        re = "rebase -i";
        rv = "remote -v";
        sdiff = "!git diff && git submodule foreach 'git diff'";
        spush = "push --recurse-submodules=on-demand";
        st = "status";
        stal = "stash pop";
        stap = "stash push";
        supdate = "submodule update --init --recursive";
        tag = "tag -a -s";
      };

      branch.autosetuprebase = "always";

      commit.status = false;

      core = {
        commentchar = ";";
        editor = "nvim -f";
      };

      credential = {
        helper = "osxkeychain";
        # The empty first entry resets any inherited helper so gh is the only
        # one consulted for these two hosts.
        "https://github.com".helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
        "https://gist.github.com".helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
      };

      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };

      github.user = "henrilhos";

      gpg.ssh.allowedSignersfile = "~/.ssh/allowed_signers";

      init.defaultbranch = "main";

      pull = {
        autostash = true;
        rebase = true;
      };

      push = {
        autosetupremote = true;
        default = "simple";
        recursesubmodules = "check";
      };

      rebase = {
        autosquash = true;
        autostash = true;
      };

      tag.sort = "-taggerdate:iso";
    };
  };

  # What `git log --show-signature` checks commits against.
  home.file.".ssh/allowed_signers".text =
    "hello@henrique.zip ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGIa977/ftf7GB5CJq0K/nP9aDgdKOPJeHMwjY0GHYN\n";
}
