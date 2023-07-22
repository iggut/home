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

  #Hyprland
  environment = {
    sessionVariables = {
      EDITOR = "code";
      #BROWSER = "brave";
      TERMINAL = "kitty";
      #LAUNCHER = "nwg-drawer";

      NIXOS_OZONE_WL = "1";
      __GL_GSYNC_ALLOWED = "0";
      __GL_VRR_ALLOWED = "0";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      DISABLE_QT5_COMPAT = "0";
      GDK_BACKEND = "wayland,x11";
      ANKI_WAYLAND = "1";
      DIRENV_LOG_FORMAT = "";
      WLR_DRM_NO_ATOMIC = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      MOZ_ENABLE_WAYLAND = "1";
      WLR_BACKEND = "vulkan";
      WLR_RENDERER = "vulkan";
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_SESSION_TYPE = "wayland";
      #SDL_VIDEODRIVER = "wayland";
    };
  };
  environment.variables = {
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  environment.systemPackages = with pkgs; [
    nvtop-nvidia
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];
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
