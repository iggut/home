{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.laptop.enable {
  services.auto-cpufreq.enable = true;
  environment.systemPackages = [pkgs.brightnessctl];

  nvidia = {
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      reverseSync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
