{ pkgs ? null
, system ? builtins.currentSystem
, configuration ? <nix-profile-config>
}:

let
  # Awkward hack to allow callPackage-ing
  nixpkgsPath =
    if isNull pkgs
    then <nixpkgs>
    else pkgs.path;

  eval = import (nixpkgsPath + /nixos/lib/eval-config.nix) {
    inherit system;

    # Use our own base modules instead of NixOS's, this is where all of
    # the core functionality of nix-profile-declarative is.
    baseModules =
      (import ./modules/module-list.nix)
      ++ [
        # These are impossible to remove due to eval-config requiring
        # misc/nixpkgs and misc/nixpkgs requiring misc/assertions+meta
        # unless I want to reimplement `_module.args.pkgs`.
        (nixpkgsPath + /nixos/modules/misc/nixpkgs.nix)
        (nixpkgsPath + /nixos/modules/misc/meta.nix)
        (nixpkgsPath + /nixos/modules/misc/assertions.nix)
      ];

    # If you don't set this, eval-config will read from the
    # NIXOS_EXTRA_MODULE_PATH environmental variable.
    extraModules = [];

    # eval-config.nix automatically sets this to
    # <nixpkgs/nixos/modules> so we need to overwrite it.
    specialArgs = {
      modulesPath = builtins.toString ./modules;
    };

    modules = [ configuration ];
  };
in {
  inherit (eval) pkgs config options;

  profile = eval.config.profile.build.toplevel;
}
