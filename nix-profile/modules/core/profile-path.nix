{ config, pkgs, lib, ... }:

with lib;

let
  profile-path = import ../../lib/build-profile.nix {
    inherit (pkgs) writeText system;
    name = "nix-profile";
    packages = config.profilePackages;
  };
in {
  options = {
    profilePackages = mkOption {
      type = types.listOf types.package;
      default = [];
      defaultText = literalExample "[]";
      example = literalExample "[ pkgs.firefox pkgs.thunderbird ]";
      description = ''
        The set of packages installed in your profile.
      '';
    };
  };
  config = {
    profile.build.path = profile-path;
  };
}
