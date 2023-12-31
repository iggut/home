### DESKTOP POWERED BY GNOME ###
{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./home-main.nix
  ]; # Setup home manager

  # Set your time zone
  time.timeZone = "America/Toronto";

  # Set your locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_MEASUREMENT = "en_CA.UTF-8";
      LANGUAGE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_CA.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  services = {
    xserver = {
      enable = true; # Enable the X11 windowing system
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
    firewall.enable = false;
  };

  security.sudo.extraConfig = "Defaults pwfeedback"; # Show asterisks when typing password

  programs.command-not-found.enable = false;

  programs.nix-index.enableZshIntegration = true;

  security.pam.services.gdm.enableGnomeKeyring = true;
  services.xserver.displayManager.defaultSession = "hyprland";

  services = {
    gnome.gnome-keyring.enable = true;
    flatpak.enable = true;
    printing.enable = true;
    printing.drivers = [
      pkgs.gutenprint
      pkgs.gutenprintBin
    ];
  };

  programs.dconf.enable = true;
  programs.partition-manager.enable = true;

  # Power profiles daemon
  services.power-profiles-daemon.enable = true;

  # LAN discovery
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  environment = {
    sessionVariables = {
      # These are the defaults, and xdg.enable does set them, but due to load
      # order, they're not set before environment.variables are set, which could
      # cause race conditions.
      MOZ_USE_XINPUT2 = "1";
      QT_QPA_PLATFORM = "wayland";
      NIXOS_OZONE_WL = "1";
      #SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      XDG_DATA_HOME = "$HOME/.local/share";
    };

    # Packages to install for all window manager/desktop environments
    systemPackages = with pkgs; [
      libinput-gestures
      resvg
      sshfs
      bibata-cursors # Material cursors
      fragments # Bittorrent client following Gnome UI standards
      gnome.adwaita-icon-theme # GTK theme
      gnome.dconf-editor # Edit gnome's dconf
      gnome.gnome-boxes # VM manager
      gnome.gnome-keyring # Gnome keyring
      gthumb # Image viewer
      gtk-engine-murrine # Theme engine needed by Orchis theme
      orchis-theme # GTK theme
      pitivi # Video editor
      qgnomeplatform # Use GTK theme for QT apps
      sops
      tela-icon-theme # Icon theme
      egl-wayland
    ];

    # Move ~/.Xauthority out of $HOME (setting XAUTHORITY early isn't enough)
    extraInit = ''
      export XAUTHORITY=/tmp/Xauthority
      [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
    '';
  };

  # Define the default fonts Fira Sans & Jetbrains Mono Nerd Fonts
  fonts = {
    fonts = with pkgs; [
      fira
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
        ];
      })
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];
    fontconfig = {
      cache32Bit = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["JetBrains Mono Nerd Font" "Noto Fonts Emoji"];
        sansSerif = ["Fira" "Noto Fonts Emoji"];
        serif = ["Fira" "Noto Fonts Emoji"];
      };
      # This fixes emoji stuff
      enable = true;
    };
    fontDir = {
      enable = true;
      decompressFonts = true;
    };
  };
}
