{ lib, ... }:
{
  options.home.email = lib.mkOption {
    type = lib.types.str;
    description = "Email address for user configuration";
  };
}
