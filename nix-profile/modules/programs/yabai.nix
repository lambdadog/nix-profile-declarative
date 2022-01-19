# Doesn't currently handle startup since we have no scaffolding for
# that yet. Does ensure scripting addon can be started.

{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.yabai;

  ensure-yabai-sa = {
    name = "Ensure yabai scripting additions";
    script = ''
    echo -n "Attempting to load yabai scripting additions..."
    if sudo -kn ${cfg.package}/bin/yabai --load-sa &>/dev/null; then
        echo " Loaded!"
    else
        echo " Failed! Don't worry, this just indicates a yabai update."
        echo "Installing new scripting additions."
        sudo ${cfg.package}/bin/yabai --install-sa &>/dev/null
        echo
        echo "Writing /private/etc/sudoers.d/yabai:"
        echo "$USER ALL=NOPASSWD:$(readlink -f ${cfg.package}/bin/yabai) --load-sa" | sudo EDITOR="tee" visudo -f /private/etc/sudoers.d/yabai
        echo
        echo -n "Trying again..."
        sudo -kn ${cfg.package}/bin/yabai --load-sa &>/dev/null \
	          && echo " Loaded!" \
	          || echo " Failed!\nContinuing without loading yabai scripting addition."
    fi
    '';
  };
in {
  options = {
    programs.yabai = {
      enable = mkEnableOption "yabai";
      package = mkOption {
        type = types.package;
        default = pkgs.yabai;
        defaultText = literalExample "pkgs.yabai";
        description = ''
          The yabai package.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    packages = [ cfg.package ];
    profile.onSwitch = [ ensure-yabai-sa ];
  };
}
