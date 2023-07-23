{
  pkgs,
  config,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [];
    };

    kernelModules = [
      "kvm_intel"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "vhost_vsock"
    ];

    blacklistedKernelModules = ["nouveau"];

    binfmt.emulatedSystems = ["aarch64-linux"];

    loader = {
      # Allows discovery of UEFI disks
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = config.efi-mount-path;
      };

      # Use systemd boot instead of grub
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "max"; # Select the highest resolution for the bootloader
      };

      timeout = 1; # Boot default entry after 1 second
    };

    plymouth.enable = config.boot.animation.enable;
  };
}
