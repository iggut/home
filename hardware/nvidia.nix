{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}:
lib.mkIf config.nvidia.enable {
  #Nvidia
  services.xserver.videoDrivers = ["nvidia"];
  #Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  hardware = {
    enableAllFirmware = true;

    opengl = {
      extraPackages = with pkgs; [vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl];
      extraPackages32 = with pkgs.pkgsi686Linux; [vaapiIntel libvdpau-va-gl vaapiVdpau];
    };

    nvidia = {
      modesetting.enable = true;
    };
  };

  virtualisation.docker.enableNvidia = true; # Enable nvidia gpu acceleration for docker

  #Hyprland
  environment = {
    sessionVariables = {
      EDITOR = "code";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      LAUNCHER = "nwg-drawer";
    };
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
