{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-manager-qt
    yubico-pam
    yubico-piv-tool
    yubioath-flutter
    yubikey-personalization-gui
    gnome.gnome-tweaks
    gnome.gnome-keyring
    pam_u2f
  ];

  services = {
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
    dbus = {
      enable = true;
      # Make the gnome keyring work properly
      packages = [pkgs.gcr];
    };

    gnome.gnome-keyring.enable = true;
  };

  # Enable the smartcard daemon
  hardware.gpgSmartcards.enable = true;

  # Configure as challenge-response for instant login,
  # can't provide the secrets as the challenge gets updated
  security.pam.yubico = {
    debug = true;
    enable = true;
    mode = "challenge-response";
    id = ["23911227"];
  };
  security.polkit.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
}
