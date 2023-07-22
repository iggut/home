{
  config,
  pkgs,
  lib,
  inputs,
  chaotic,
  ...
}: {
  environment.systemPackages = with pkgs; [
    goverlay
    osu-lazer-bin
    protonup-qt
    lutris
    ###########
    ananicy-cpp
    ananicy-cpp-rules
    appmenu-gtk3-module
    droid-sans-mono-nerdfont
    fastfetch
    input-leap_git
    #yuzu-early-access_git
  ];

  #Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # improvement for games using lots of mmaps (same as steam deck)
  boot.kernel.sysctl = {"vm.max_map_count" = 2147483642;};

  #Enable Gamescope
  programs.gamescope = {
    enable = true;
    package = pkgs.gamescope_git;
    capSysNice = true;
    #args = ["--prefer-vk-device 10de:2206"];
    #env = {
    #  "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    #  "MESA_VK_DEVICE_SELECT" = "pci:10de:2206";
    #};
  };

  # Enable gamemode
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
      custom = {
        start = "notify-send -a 'Gamemode' 'Optimizations activated'";
        end = "notify-send -a 'Gamemode' 'Optimizations deactivated'";
      };
    };
  };
}
