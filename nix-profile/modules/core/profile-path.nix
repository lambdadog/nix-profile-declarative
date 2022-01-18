{ config, pkgs, lib, ... }:

with lib;

let
  profile-path = import ../../lib/build-profile.nix {
    inherit (pkgs) writeText system;
    inherit (config.profile) static;
    inherit (config) packages;
    name = "nix-profile";
  };
in {
  options = {
    packages = mkOption {
      type = types.listOf types.package;
      default = [];
      defaultText = literalExample "[]";
      example = literalExample "[ pkgs.firefox pkgs.thunderbird ]";
      description = ''
        The set of packages installed in your profile.
      '';
    };

    profile.static = mkOption {
      type = types.bool;
      default = false;
      defaultText = literalExample "false";
      example = literalExample "true";
      description = ''
        Whether to disallow imperative modification of the nix profile
        with nix-env.
      '';
    };
  };
  config = {
    profile.build.path = profile-path;
  };
}
