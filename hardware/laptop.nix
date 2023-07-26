{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.laptop.enable {
  services.auto-cpufreq.enable = true;
  environment.systemPackages = [pkgs.brightnessctl];

  hardware = {
    nvidia = {
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  #fix Gamescope glitchy graphics intel/nvidia
  programs.gamescope = {
    env = {
      "INTEL_DEBUG" = "noccs";
    };
  };
}
