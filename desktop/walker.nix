{ pkgs, ... }:

{
  programs.walker = {
    enable = true;
    runAsService = true;
  };
  systemd.user.services.elephant = {
    serviceConfig = {
      ExecStart = "${pkgs.walker}/bin/elephant";
      Restart = "always";
      RuntimeDirectory = "elephant";
    };
  };
}
