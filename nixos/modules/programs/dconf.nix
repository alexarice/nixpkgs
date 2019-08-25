{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dconf;

  mkDconfProfile = name: path: nameValuePair "dconf/profile/${name}" { source = path; };

in
{
  ###### interface

  options = {
    programs.dconf = {
      enable = mkEnableOption "dconf";

      profiles = mkOption {
        type = types.attrsOf types.path;
        default = {};
        description = "Set of dconf profile files.";
        internal = true;
      };

    };
  };

  ###### implementation

  config = mkIf (cfg.profiles != {} || cfg.enable) {
    environment.etc = mapAttrs' mkDconfProfile cfg.profiles;

    services.dbus.packages = [ pkgs.gnome3.dconf ];

    # For dconf executable
    environment.systemPackages = [ pkgs.gnome3.dconf ];

    # Needed for unwrapped applications
    environment.variables.GIO_EXTRA_MODULES = mkIf cfg.enable [ "${pkgs.gnome3.dconf.lib}/lib/gio/modules" ];
  };

}
