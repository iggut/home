{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf config.nvidia.enable {
  services.xserver.videoDrivers = ["nvidia"]; # Install the nvidia drivers

  hardware.nvidia.modesetting.enable = true; # Required for wayland

  virtualisation.docker.enableNvidia = true; # Enable nvidia gpu acceleration for docker

  environment.systemPackages = [pkgs.nvtop-nvidia]; # Monitoring tool for nvidia GPUs

  #Hyprland
  home = {
    sessionVariables = {
      #EDITOR = "code";
      #BROWSER = "brave";
      TERMINAL = "kitty";
      #LAUNCHER = "nwg-drawer";

      #QT_QPA_PLATFORMTHEME = "gnome";
      #QT_SCALE_FACTOR = "1";
      MOZ_ENABLE_WAYLAND = "1";
      #SDL_VIDEODRIVER = "wayland";
      #_JAVA_AWT_WM_NONREPARENTING = "1";
      #QT_QPA_PLATFORM = "wayland";
      #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      #QT_AUTO_SCREEN_SCALE_FACTOR = "1";

      WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line
      #WLR_RENDERER_ALLOW_SOFTWARE = "1";
      # GBM_BACKEND = "nvidia-drm";
      #CLUTTER_BACKEND = "wayland";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      WLR_RENDERER = "vulkan";
    };
  };

  # Set nvidia gpu power limit
  systemd.services.nv-power-limit = lib.mkIf config.nvidia.power-limit.enable {
    enable = true;
    description = "Nvidia power limit control";
    after = ["syslog.target" "systemd-modules-load.service"];

    unitConfig = {
      ConditionPathExists = "${config.boot.kernelPackages.nvidia_x11.bin}/bin/nvidia-smi";
    };

    serviceConfig = {
      User = "root";
      ExecStart = "${config.boot.kernelPackages.nvidia_x11.bin}/bin/nvidia-smi  --power-limit=${config.nvidia.power-limit.value}";
    };

    wantedBy = ["multi-user.target"];
  };
}
