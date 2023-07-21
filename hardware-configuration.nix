{inputs, ...}: {
  swapDevices = [
    {
      device = "/.swap/swapfile";
      size = 2048;
    }
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
