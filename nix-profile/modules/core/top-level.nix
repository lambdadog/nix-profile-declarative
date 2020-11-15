{ config, pkgs, lib, ... }:

with lib;

let
  switch-to-profile = pkgs.writeShellScript "switch-to-profile" ''
    nix-env --set ${config.profile.build.path}
  '';
  profile = pkgs.runCommand "nix-profile" {} ''
    mkdir -p $out
    ln -s ${config.profile.build.path} $out/profile

    mkdir -p $out/bin/
    cp ${switch-to-profile} $out/bin/switch-to-profile
  '';
in {
  options = {
    profile.build = mkOption {
      internal = true;
      default = {};
      type = types.attrs;
      description = ''
        Attribute set of derivations used to setup the system.
      '';
    };
  };
  config = {
    profile.build.toplevel = profile;
  };
}
