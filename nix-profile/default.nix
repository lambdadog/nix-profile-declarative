{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
, configuration ? <nix-profile-config>
}:

let
  eval = import (nixpkgs + /nixos/lib/eval-config.nix) {
    inherit system;

    # Use our own base modules instead of NixOS's, this is where all of
    # the core functionality of nix-profile-declarative is.
    baseModules =
      (import ./modules/module-list.nix)
      ++ [
        (nixpkgs + /nixos/modules/misc/nixpkgs.nix)
        (nixpkgs + /nixos/modules/misc/assertions.nix)
      ];

    # override NIXOS_EXTRA_MODULE_PATH
    extraModules = [];

    modules = [ configuration ];
  };
in {
  inherit (eval) pkgs config options;

  system = eval.config.profile.build.toplevel;
}
