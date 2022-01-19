{ config, pkgs, lib, ... }:

with lib;

let
  switch-to-profile = pkgs.writeShellScript "switch-to-profile" ''
    ${concatStringsSep "\n\n" config.profile.build.onSwitch}

    ${pkgs.nix}/bin/nix-env --set ${config.profile.build.path}
  '';
  profile-closure = pkgs.runCommand "nix-profile" {} ''
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
    profile.build.toplevel = profile-closure;
  };
}
