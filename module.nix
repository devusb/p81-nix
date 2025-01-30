{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mdDoc
    mkIf
    mkPackageOption
    ;
  cfg = config.services.perimeter81;
in
{
  options = {
    services.perimeter81 = {
      enable = mkEnableOption (mdDoc "Perimeter81 VPN client");
      package = mkPackageOption pkgs "perimeter81" { };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services = {
      "perimeter81-helper-daemon" = {
        description = "Perimeter81 Helper Daemon";
        wants = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        requires = [
          "network-online.target"
        ];
        after = [
          "NetworkManager.service"
          "systemd-resolved.service"
        ];

        serviceConfig = {
          ExecStartPre = pkgs.writeShellScript "p81-setup" ''
            mkdir -p /var/lib/p81/local
            mkdir -p /var/lib/p81/etc
          '';
          ExecStart = "${cfg.package}/bin/p81-helper-daemon";
          ExecStop = "${cfg.package}/bin/p81-helper-daemon stop";
          Restart = "always";
          SyslogIdentifier = "perimeter81helper";
          User = "root";
          Group = "root";
          WorkingDirectory = "/";
        };
      };
    };
  };
}
