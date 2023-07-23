{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf config.main.user.enable {
  home-manager.users.${config.main.user.username} = {
    imports = [
      ./vscode.nix
    ];
    programs = {
      git = {
        enable = true;
        # Git config
        userName = "${config.main.user.github.username}";
        userEmail = "${config.main.user.github.email}";
      };

      kitty = {
        enable = true;
        settings = {
          background_opacity = "0.8";
          confirm_os_window_close = "0";
          cursor_shape = "beam";
          enable_audio_bell = "no";
          hide_window_decorations = "yes";
          update_check_interval = "0";
          copy_on_select = "no";
        };
        font.name = "JetBrainsMono Nerd Font";
        font.size = 10;
        theme = "Catppuccin-Mocha";
      };

      mangohud = {
        enable = true;
        # Mangohud config
        settings = {
          background_alpha = 0;
          cpu_color = "FFFFFF";
          cpu_temp = true;
          engine_color = "FFFFFF";
          font_size = 20;
          fps = true;
          fps_limit = "144+60+0";
          frame_timing = 0;
          gamemode = true;
          gl_vsync = 0;
          gpu_color = "FFFFFF";
          gpu_temp = true;
          no_small_font = true;
          offset_x = 50;
          position = "top-right";
          toggle_fps_limit = "Ctrl_L+Shift_L+F1";
          vsync = 1;
        };
      };

      zsh = {
        enable = true;
        # Enable firefox wayland
        profileExtra = "export MOZ_ENABLE_WAYLAND=1";

        # Install powerlevel10k
        plugins = with pkgs; [
          {
            name = "powerlevel10k";
            src = zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "zsh-nix-shell";
            file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
            src = zsh-nix-shell;
          }
        ];

        initExtra = ''eval "$(direnv hook zsh)"'';
      };

      firefox = {
        enable = true;
        profiles.default = {
          id = 0;
          name = "Default";
          extensions = with config.nur.repos.rycee.firefox-addons; [
            reddit-enhancement-suite
            bypass-paywalls-clean
            enhancer-for-youtube
            gesturefy
            protondb-for-steam
            istilldontcareaboutcookies
            enhanced-github
            onepassword-password-manager
            df-youtube
            darkreader
            ublock-origin
            youchoose-ai
          ];
          search = {
            default = "Google";
            force = true;
            engines = {
              "Nix Packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = ["@np"];
              };

              "NixOS Wiki" = {
                urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
                iconUpdateURL = "https://nixos.wiki/favicon.png";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = ["@nw"];
              };

              "Bing".metaData.hidden = true;
              "DuckDuckGo".metaData.hidden = true;
              "Amazon.nl".metaData.hidden = true;
              "eBay".metaData.hidden = true;
              "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
            };
          };
          settings = {
            # Browser settings go here
            "browser.startup.homepage" = "";
            # Enable HTTPS-Only Mode
            "dom.security.https_only_mode" = true;
            "dom.security.https_only_mode_ever_enabled" = true;
            # Privacy settings
            "privacy.donottrackheader.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.partition.network_state.ocsp_cache" = true;
            # Disable all sorts of telemetry
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.updatePing.enabled" = false;

            # As well as Firefox 'experiments'
            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.supported" = false;
            "network.allow-experiments" = false;
            # Disable Pocket Integration
            "browser.newtabpage.activity-stream.section.highlights.includePocket" =
              false;
            "extensions.pocket.enabled" = false;
            "extensions.pocket.api" = "";
            "extensions.pocket.oAuthConsumerKey" = "";
            "extensions.pocket.showHome" = false;
            "extensions.pocket.site" = "";
            # Allow copy to clipboard
            "dom.events.asyncClipboard.clipboardItem" = true;
          };
        };
      };
    };

    home.file = {
      # Add zsh theme to zsh directory
      ".config/zsh/zsh-theme.zsh" = {
        source = ../configs/zsh-theme.zsh;
        recursive = true;
      };

      # Add proton-ge-updater script to zsh directory
      ".config/zsh/proton-ge-updater.sh" = {
        source = ../scripts/proton-ge-updater.sh;
        recursive = true;
      };

      # Add steam-library-patcher to zsh directory
      ".config/zsh/steam-library-patcher.sh" = {
        source = ../scripts/steam-library-patcher.sh;
        recursive = true;
      };

      # Set firefox to privacy profile
      #".mozilla/firefox/profiles.ini" = {
      #  source = ../configs/firefox/profiles.ini;
      #  recursive = true;
      #};

      # Add user.js
      #".mozilla/firefox/privacy/user.js" = {
      #  source =
      #    if (config.firefox.privacy.enable)
      #    then "${(pkgs.callPackage ../programs/self-built/arkenfox-userjs.nix {})}/user.js"
      #    else ../configs/firefox/user.js;
      #  recursive = true;
      #};

      # Install firefox gnome theme
      #".mozilla/firefox/privacy/chrome/firefox-gnome-theme" = lib.mkIf config.firefox.gnome-theme.enable {
      #  source = pkgs.callPackage ../programs/self-built/firefox-gnome-theme.nix {};
      #  recursive = true;
      #};

      # Import firefox gnome theme userChrome.css
      ".mozilla/firefox/default/chrome/userChrome.css" = {
        source = ../configs/firefox/userChrome.css;
        recursive = true;
      };

      # Import firefox gnome theme userContent.css
      ".mozilla/firefox/default/chrome/userContent.css" = {
        source = ../configs/firefox/userContent.css;
        recursive = true;
      };

      # Import firefox gnome theme files
      ".mozilla/firefox/default/chrome/cleaner_extensions_menu.css" = {
        source = ../configs/firefox/cleaner_extensions_menu.css;
        recursive = true;
      };
      ".mozilla/firefox/default/chrome/firefox_view_icon_change.css" = {
        source = ../configs/firefox/firefox_view_icon_change.css;
        recursive = true;
      };
      ".mozilla/firefox/default/chrome/spill-style-part1-file.css" = {
        source = ../configs/firefox/spill-style-part1-file.css;
        recursive = true;
      };
      ".mozilla/firefox/default/chrome/colored_soundplaying_tab.css" = {
        source = ../configs/firefox/colored_soundplaying_tab.css;
        recursive = true;
      };
      ".mozilla/firefox/default/chrome/popout_bookmarks_bar_on_hover.css" = {
        source = ../configs/firefox/popout_bookmarks_bar_on_hover.css;
        recursive = true;
      };
      ".mozilla/firefox/default/chrome/spill-style-part2-file.css" = {
        source = ../configs/firefox/spill-style-part2-file.css;
        recursive = true;
      };
      ".mozilla/firefox/default/chrome/image" = {
        source = ../configs/firefox/image;
        recursive = true;
      };

      # Create second firefox profile for element
      #".mozilla/firefox/element/user.js" = {
      #  source = "${(pkgs.callPackage ../programs/self-built/arkenfox-userjs.nix {})}/user.js";
      #  recursive = true;
      #};

      #".mozilla/firefox/element/chrome" = {
      #  source = pkgs.callPackage ../programs/self-built/firefox-cascade.nix {};
      #  recursive = true;
      #};

      # Add noise suppression microphone
      ".config/pipewire/pipewire.conf.d/99-input-denoising.conf" = {
        source = ../configs/pipewire.conf;
        recursive = true;
      };

      # Add btop config
      ".config/btop/btop.conf" = {
        source = ../configs/btop.conf;
        recursive = true;
      };

      # Add adwaita steam skin
      ".local/share/Steam/steamui/libraryroot.custom.css" = {
        source = "${(pkgs.callPackage ../programs/self-built/adwaita-for-steam {})}/build/libraryroot.custom.css";
        recursive = true;
      };

      # Enable steam beta
      ".local/share/Steam/package/beta" = lib.mkIf config.steam.beta.enable {
        text = "publicbeta";
        recursive = true;
      };

      # Add custom mangohud config for CS:GO
      ".config/MangoHud/csgo_linux64.conf" = {
        text = ''
          background_alpha=0
          cpu_color=FFFFFF
          cpu_temp
          engine_color=FFFFFF
          font_size=20
          fps
          fps_limit=0+144
          frame_timing=0
          gamemode
          gl_vsync=0
          gpu_color=FFFFFF
          gpu_temp
          no_small_font
          offset_x=50
          position=top-right
          toggle_fps_limit=Ctrl_L+Shift_L+F1
          vsync=1
        '';
        recursive = true;
      };

      # Add custom mangohud config for CS2
      ".config/MangoHud/wine-cs2.conf" = {
        text = ''
          background_alpha=0
          cpu_color=FFFFFF
          cpu_temp
          engine_color=FFFFFF
          font_size=20
          fps
          fps_limit=0+144
          frame_timing=0
          gamemode
          gl_vsync=0
          gpu_color=FFFFFF
          gpu_temp
          no_small_font
          offset_x=50
          position=top-right
          toggle_fps_limit=Ctrl_L+Shift_L+F1
          vsync=1
        '';
        recursive = true;
      };

      # Add nvchad
      ".config/nvim" = {
        source = "${(pkgs.callPackage ../programs/self-built/nvchad.nix {})}";
        recursive = true;
      };

      ".config/nvim/lua/custom" = {
        source = ../configs/nvchad;
        recursive = true;
        force = true;
      };

      # Add tmux
      ".config/tmux/tmux.conf" = {
        source = ../configs/tmux.conf;
        recursive = true;
      };

      ".config/tmux/tpm" = {
        source = "${(pkgs.callPackage ../programs/self-built/tpm.nix {})}";
        recursive = true;
      };
    };

    xdg.desktopEntries.element = {
      exec = "firefox --no-remote -P Element --name element https://icedborn.github.io/element-web https://discord.com/app";
      icon = "element";
      name = "Element";
      terminal = false;
      type = "Application";
    };
  };
}
