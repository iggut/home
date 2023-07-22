### DESKTOP POWERED BY GNOME ###
{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./home-main.nix
    ./home-work.nix
  ]; # Setup home manager

  # Set your time zone
  time.timeZone = "America/Toronto";

  # Set your locale settings
  i18n = {
    defaultLocale = "en_US.utf8";
    extraLocaleSettings.LC_MEASUREMENT = "en_CA.utf8";
  };

  services = {
    xserver = {
      enable = true; # Enable the X11 windowing system
      windowManager.openbox.enable = true;
      displayManager = {
        gdm = {
          enable = true;
          autoSuspend = config.desktop-environment.gdm.auto-suspend.enable;
        };

        autoLogin = lib.mkIf config.boot.autologin.enable {
          enable = true;
          user =
            if (config.main.user.enable && config.boot.autologin.main.user.enable)
            then config.main.user.username
            else if (config.work.user.enable)
            then config.work.user.username
            else "";
        };
      };

      layout = "us";
    };

    # Enable sound with pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Workaround for GDM autologin
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true; # Enable service which hands out realtime scheduling priority to user processes on demand, required by pipewire

  networking = {
    networkmanager.enable = true;
    hostName = "gaminix";
    firewall.enable = false;
  };

  security.sudo.extraConfig = "Defaults pwfeedback"; # Show asterisks when typing sudo password

  programs.command-not-found.enable = false;

  programs.nix-index.enableZshIntegration = true;

  environment = {
    # Packages to install for all window manager/desktop environments
    systemPackages = with pkgs; [
      bibata-cursors # Material cursors
      fragments # Bittorrent client following Gnome UI standards
      gnome.adwaita-icon-theme # GTK theme
      gnome.gnome-boxes # VM manager
      gthumb # Image viewer
      pitivi # Video editor
      tela-icon-theme # Icon theme
    ];
    # Move ~/.Xauthority out of $HOME (setting XAUTHORITY early isn't enough)
    extraInit = ''
      export XAUTHORITY=/tmp/Xauthority
      [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
    '';
  };

  fonts.fonts = with pkgs; [
    meslo-lgs-nf
    cantarell-fonts
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];
}
