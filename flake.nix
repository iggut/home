{
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    pipewire-screenaudio.url = "github:IceDBorn/pipewire-screenaudio";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    hyprland,
    home-manager,
    nur,
    disko,
    nixos-hardware,
    pipewire-screenaudio,
  } @ inputs: {
    nixosConfigurations = {
      gaminix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-nvidia
          nixos-hardware.nixosModules.common-pc
          nixos-hardware.nixosModules.common-pc-ssd
          disko.nixosModules.disko
          (import ./disko-config.nix {})

          {
            nixpkgs.config.permittedInsecurePackages = [
              "openssl-1.1.1u"
            ];
          }
          nur.nixosModules.nur
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
          {
            programs.hyprland.enable = true;
            programs.hyprland.nvidiaPatches = true;
            programs.hyprland.xwayland.enable = true;
          }
          ./configuration.nix
        ];
      };
    };
  };
}
