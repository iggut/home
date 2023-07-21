{
  config,
  lib,
  ...
}:
lib.mkIf config.main.user.enable {
  users.users.${config.main.user.username} = {
    createHome = true;
    home = "/home/${config.main.user.username}";
    useDefaultShell = true;
    password = "1"; # Default password used for first login, change later with passwd
    isNormalUser = true;
    description = "${config.main.user.description}";
    extraGroups = ["networkmanager" "wheel" "kvm" "docker" "input"];
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-persistenced"
      "nvidia-x11"
      "nvidia-settings"
      "1password"
      "1password-cli"
      "steam"
      "steam-run"
      "steam-original"
      "vscode"
    ];

  home-manager.users.${config.main.user.username}.home = {
    stateVersion = config.state-version;
    file.".nix-successful-build" = {
      text = "true";
      recursive = true;
    };
  };
}
