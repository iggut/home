{
  lib,
  config,
  pkgs,
  ...
}: let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  hardware = {
    nvidia = {
      nvidiaPersistenced = true;
      powerManagement.enable = true;
      # Modesetting is needed for most wayland compositors
      modesetting.enable = true;
      # Use the open source version of the kernel module
      # Only available on driver 515.43.04+
      open = true;
      # Enable the nvidia settings menu
      nvidiaSettings = false;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
    opengl = {
      extraPackages = with pkgs; [vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl];
      extraPackages32 = with pkgs.pkgsi686Linux; [vaapiIntel libvdpau-va-gl vaapiVdpau];
    };
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  services.acpid.enable = true;

  environment.systemPackages = lib.mkIf (config.laptop.enable && config.nvidia.enable) [nvidia-offload]; # Use nvidia-offload to launch programs using the nvidia GPU

  # Set memory limits
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "memlock";
      value = "2147483648";
    }

    {
      domain = "*";
      type = "soft";
      item = "memlock";
      value = "2147483648";
    }
  ];

  boot = {
    kernelModules = [
      "v4l2loopback" # Virtual camera
      "xpadneo"
      "uinput"
    ];

    kernelParams = ["clearcpuid=514"]; # Fixes certain wine games crash on launch

    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  };

  fileSystems = lib.mkIf (config.boot.btrfs-compression.enable && config.boot.btrfs-compression.root.enable) {
    "/".options = ["compress=zstd"];
  };
}
