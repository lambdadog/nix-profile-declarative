{ config, pkgs, lib, ... }:

with lib;

let
  profile = import ../../lib/build-profile.nix {
    inherit (pkgs) writeText system;
    name = "nix-profile";
    packages = config.unwrappedPackages;
  };
in {
  options = {
    unwrappedPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      example = literalExample "[ pkgs.firefox pkgs.thunderbird ]";
      description = ''
        The set of packages installed in your profile. The name is
        a slight misnomer, seeing as this is also where your wrapped
        packages end up in the end.
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
    profile.path = profile;
  };
}
