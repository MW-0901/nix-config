{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.swayosd
  ];
  systemd.user.services.swayosd = {
    enable = true;
    description = "SwayOSD Daemon";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
      Restart = "always";
    };
  };
}
