{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    (import ./disko-config.nix {})
    (modulesPath + "/installer/scan/not-detected.nix")

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  services.fwupd.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";

  hardware = {
    enableAllFirmware = true;
  };

  swapDevices = [
    {
      device = "/.swap/swapfile";
      size = 2048;
    }
  ];
}
