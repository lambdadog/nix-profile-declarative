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
        # These are impossible to remove due to eval-config requiring
        # misc/nixpkgs and misc/nixpkgs requiring misc/assertions
        (nixpkgs + /nixos/modules/misc/nixpkgs.nix)
        (nixpkgs + /nixos/modules/misc/assertions.nix)
      ];

    # If you don't set this, eval-config will read from the
    # NIXOS_EXTRA_MODULE_PATH environmental variable
    extraModules = [];

    modules = [ configuration ];
  };
in {
  inherit (eval) pkgs config options;

  profile = eval.config.profile.build.toplevel;
}
