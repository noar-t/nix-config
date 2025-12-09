{ specialArgs, ... }:
{
  # version control
  programs.git =
    let
      inherit (specialArgs.profile) email;
    in
    {
      enable = true;

      ignores = [
        # vim
        "*swp"

        # JVM
        "*iml"
        "*.class"
        "*.classpath"
        "*.factorypath"
        ".project"
        ".settings/"
        ".kls_database.db"
        "kotlinLspClasspath.sh"

        # nix
        "result/"

        # claude
        "CLAUDE.md"
        ".claude/"
      ];

      settings = {
        user.name = "Noah Thornton";
        user.email = email;
        branch.sort = "-committerdate"; # sort branches by activity
        help.autocorrect = "1"; # fix typos in git commands
        init.defaultBranch = "master"; # default branch when repo init
        pull.rebase = true; # always rebase when pulling
        rebase.autostash = true; # auto stash when rebasing
        rerere.enabled = true; # remember conflict resolutions
        rerere.autoupdate = true;
        # TODO try out meld merget tool
      };
    };

  # improved difftool
  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
}
