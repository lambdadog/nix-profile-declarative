{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.emacs;

  emacsWrapped =
    let
      emacs = pkgs.emacsWithPackages cfg.emacsPackages;
      configFile =
        if builtins.isPath cfg.config
        then if pathIsDirectory cfg.config
          then "${pkgs.copyPathToStore cfg.config}/init.el"
          else cfg.config
        else if builtins.isString cfg.config
          then pkgs.writeText "init.el" cfg.config
        else if isDerivation cfg.config
          # We can't use pathIsDirectory on derivations, so whether or
          # not it's a directory needs to be checked at build time. This
          # `true` is a signal to do so.
          then true
        else builtins.throw "emacs config cannot be of type ${builtins.typeOf cfg.config}";
      autoloadFile = pkgs.writeText "autoload.el" ''
        ;; -*- lexical-binding: t -*-
        (dolist (dir load-path)
          (dolist (autoload (file-expand-wildcards
                  (expand-file-name "*-autoloads.el" dir)
		      		    t))
            (load autoload nil t t)))
      '';
    in pkgs.runCommand "emacs-with-config" {
      nativeBuildInputs = [ pkgs.makeWrapper emacs ];
    } ''
      ${if builtins.isBool configFile && configFile then ''
          # See if derivation is a directory or not
          configFile=$(test -d ${cfg.config} \
            && echo ${cfg.config}/init.el \
            || echo ${cfg.config})
        '' else ''
          configFile=${configFile}
        ''}

      mkdir -p "$out/bin"
      cp ${emacs}/bin/* $out/bin/
      for prog in ${emacs}/bin/{emacs,emacs-*}; do
        local progname=$(basename "$prog")
        rm -f "$out/bin/$progname"
        makeWrapper "$prog" "$out/bin/$progname" \
          ${if ! isNull cfg.config then
              if cfg.quick
                then "--add-flags \"-Q --load \"${autoloadFile}\" --load \"$configFile\"\""
                else "--add-flags \"-q --load \"${autoloadFile}\" --load \"$configFile\"\""
            else ""} \
          ${if builtins.length cfg.runtimeDependencies != 0
              then "--prefix PATH : \"${makeBinPath cfg.runtimeDependencies}\""
              else ""}
       done

       if [ -d "${emacs}/Applications/Emacs.app" ]; then
         mkdir -p "$out/Applications/Emacs.app/Contents/MacOS"
         cp -r ${emacs}/Applications/Emacs.app/Contents/Info.plist \
               ${emacs}/Applications/Emacs.app/Contents/PkgInfo \
               ${emacs}/Applications/Emacs.app/Contents/Resources \
               $out/Applications/Emacs.app/Contents
         makeWrapper "${emacs}/Applications/Emacs.app/Contents/MacOS/Emacs" \
                     "$out/Applications/Emacs.app/Contents/MacOS/Emacs" \
           ${if ! isNull cfg.config then
               if cfg.quick
                 then "--add-flags \"-Q --load \"${autoloadFile}\" --load \"$configFile\"\""
                 else "--add-flags \"-q --load \"${autoloadFile}\" --load \"$configFile\"\""
             else ""} \
           ${if builtins.length cfg.runtimeDependencies != 0
               then "--prefix PATH : \"${makeBinPath cfg.runtimeDependencies}\""
               else ""}
       fi

       mkdir -p $out/share
       # Link icons and desktop files into place
       for dir in applications icons info man; do
         ln -s $emacs/share/$dir $out/share/$dir
       done
    '';
in {
  options = {
    programs.emacs = {
      enable = mkEnableOption "emacs";

      emacsPackages = mkOption {
        # TODO: Make typeable
        # type = types.function;
        default = [];
        defaultText = literalExample "[]";
        example = literalExample "ep: with ep; [ magit nix-mode ]";
        description = ''
          A function that takes the set of emacs packages as input and
          returns a list of emacs packages to install.
        '';
      };

      quick = mkOption {
        type = types.bool;
        default = false;
        defaultText = literalExample "false";
        example = literalExample "true";
        description = ''
          Whether to start emacs with -Q instead of -q. No-op if
          `packages.emacs.config` isn't set.
        '';
      };

      config = mkOption {
        type = with types; nullOr (oneOf [ path str package ]);
        default = null;
        defaultText = literalExample "null";
        example = literalExample "./emacs.d";
        description = ''
          Your emacs configuration. Can be either a string, path, or
          derivation.

          if `config` is a string, we write it to the store (rendering
          it read-only) and tell emacs to load it directly on starting.

          If `config` is a path or derivation, we copy it to the store,
          then either load `$storepath/init.el` if it's a directory or
          `$storepath` if it's a file.

          If `config` is set, `nix-profile-declarative` automatically
          manages your autoloads, but this isn't possible if you're
          using `~/.emacs.d` or `~/.emacs`. In this case you'll need
          to add a snippet like the following to your init:

          <programlisting>
          (dolist (dir load-path)
            (dolist (autoload (file-expand-wildcards
          		     (expand-file-name "*-autoloads.el" dir)
		      		     t))
              (load autoload nil t t)))
          </programlisting>
        '';
      };

      runtimeDependencies = mkOption {
        type = with types; listOf package;
        default = [];
        defaultText = literalExample "[]";
        example = literalExample "[ ispell git imagemagickBig ]";
        description = ''
          A set of extra derivations to be added to emacs' PATH
          variable. Useful for runtime dependencies of emacs.
        '';
      };
    };
  };
  config = {
    profilePackages = mkIf cfg.enable [
      emacsWrapped
    ];
  };
}
