{
  config,
  lib,
  ...
}: {
  imports = [
    # Auto-generated configuration by NixOS
    ./hardware-configuration.nix
    # Custom configuration
    ../../.nix
    ../../bootloader
    ../../hardware # Enable various hardware capabilities
    #../../hardware/amd/radeon.nix
    #../../hardware/amd/ryzen.nix
    ../../hardware/intel.nix
    ../../hardware/laptop.nix
    ../../hardware/bluetooth.nix
    #../../hardware/mounts.nix # Disks to mount on startup
    ../../hardware/nvidia.nix
    ../../hardware/virtualisation.nix
    ../../system/desktop
    ../../system/desktop/gnome
    ../../system/desktop/hyprland
    ../../system/programs
    ../../system/users
  ];

  config.networking = {
    hostName = "gs66";
  };

  config.system.stateVersion = config.state-version;
}
