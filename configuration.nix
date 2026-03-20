# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  config,
  pkgs,
  lib,
  globalPackages ? pkgs.buildEnv { name = "empty"; paths = []; },
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./optimizations/power.nix
    ./optimizations/general.nix
    ./optimizations/security.nix
    ./optimizations/disk.nix
    ./wpilib/wpilib.nix
    ./desktop/volume.nix
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  programs.nix-ld.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.tailscale.enable = true;
  services.atd.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.niri.enable = true;
  security.pam.u2f = {
    enable = true;
    settings.cue = false;
    control = "sufficient"; # Try U2F first, skip password if successful
  };
  system.userActivationScripts.xhost = ''
    ${pkgs.xhost}/bin/xhost +local:docker
  '';
  programs.steam.enable = true; 
  programs.steam.gamescopeSession.enable = true;
  security.pam.services.doas.u2fAuth = true;
  security.pam.services.login.u2fAuth = false;
  security.pam.services.sudo.u2fAuth = false;
  security.pam.services.sddm.u2fAuth = false;
  security.pam.services.sddm.fprintAuth = false;
  security.pam.services.swaylock.u2fAuth = false;
  security.pam.services.swaylock.fprintAuth = true;
  security.pam.services.swaylock.enable = true;
  security.doas.enable = true;
  security.pam.services.doas.fprintAuth = false;
  security.doas.extraConfig = ''
    permit keepenv mark as root
  '';

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "niri";
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  services.desktopManager.gnome.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "mark";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;
  
  # Enable networking
  networking.networkmanager = {
    wifi.backend = "iwd";
    enable = true;
    dns = "none";
    unmanaged = [
      "enp0s20f0u2"
    ];
  };
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;
  services.gpm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  fonts = {
    packages = with pkgs; [
      hack-font
      nerd-fonts.hack
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Hack Nerd Font" ];
      };
    };
  };

  # Enable sound with pipewire.
  services.usbmuxd.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.mark = {
    isNormalUser = true;
    description = "Mark Wilson";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Allow unfree packages
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    globalPackages
    pkgs.hicolor-icon-theme
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
  services.logind.settings = {
    Login = {
      HandlePowerKey = "ignore";
      HandleSuspendKey = "ignore";
    };
  };
  swapDevices = [
    {
      device = "/swapfile";
      size = 36864;
    }
  ];
  boot = {
    resumeDevice = "/dev/mapper/luks-1f336063-ad19-4a6f-8d24-152aedade97a";
    kernelParams = [ "resume_offset=3033965" ];
  };
}
