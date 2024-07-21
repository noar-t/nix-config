
{ config, pkgs, specialArgs, inputs, ... }:
{
  # version control
  programs.git = let
    inherit (specialArgs.profile) email;
  in {
    enable = true;

    # improved difftool
    difftastic.enable = true;

    userName = "Noah Thornton";
    userEmail = email;

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
    ];

    # TODO git include to include options
  };
}
