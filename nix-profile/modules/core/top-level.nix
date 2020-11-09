{ config, pkgs, lib, ... }:

with lib;

let
  switch-to-profile = pkgs.writeShellScript "switch-to-profile" ''
    nix-env --set @out@/profile
  '';
  result = pkgs.runCommand "nix-profile" {} ''
    mkdir -p $out
    ln -s ${config.profile.path} $out/profile

    mkdir -p $out/bin/
    cp ${switch-to-profile} $out/bin/switch-to-profile
    substituteInPlace $out/bin/switch-to-profile --subst-var out
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
    profile.build.toplevel = result;
  };
}
