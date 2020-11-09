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
      example = literalExample "[ pkgs.firefox pkgs.thunderbird ]";
      description = ''
        The set of packages installed in your profile.
      '';
    };
    profile.path = mkOption {
      internal = true;
      description = ''
        The packages you want in the nix profile.
      '';
    };
  };
  config = {
    profile.path = profile-path;
  };
}
