{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.laptop.enable {
  services.auto-cpufreq.enable = true;
  environment.systemPackages = [pkgs.brightnessctl];

  environment.variables = {
    #LIBVA_DRIVER_NAME = "iHD";
    #VDPAU_DRIVER = "va_gl";
    WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
  };

  #Enable Gamescope
  programs.gamescope = {
    env = {
      "INTEL_DEBUG" = "noccs";
    };
  };

  hardware.nvidia = {
    prime = {
      #sync.enable = true;
      offload = {
        enable = true;
        #enableOffloadCmd = true;
      };
      #reverseSync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
