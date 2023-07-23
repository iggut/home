{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./home-main.nix
    ./home-work.nix
  ]; # Setup home manager for hyprland

  programs = lib.mkIf config.desktop-environment.hyprland.enable {
    nm-applet.enable = true; # Network manager tray icon
    kdeconnect.enable = true; # Connect phone to PC
  };

  environment = lib.mkIf config.desktop-environment.hyprland.enable {
    systemPackages = with pkgs; [
      #(callPackage ../../programs/self-built/hyprland-per-window-layout.nix {})
      # Status bar
      (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
        postPatch = ''
          sed -i 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch workspace " + name_;\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
        '';
      }))
      baobab # Disk usage analyser
      blueberry # Bluetooth manager
      clipman # Clipboard manager for wayland
      dotnet-sdk_7 # SDK for .net
      fd # Find alternative
      gdtoolkit # Tools for gdscript
      gnome.file-roller # Archive file manager
      gnome.gnome-calculator # Calculator
      gnome.gnome-disk-utility # Disks manager
      gnome.gnome-themes-extra # Adwaita GTK theme
      gnome.nautilus # File manager
      gnome.gnome-keyring
      grim # Screenshot tool
      hyprpaper # Wallpaper daemon
      jc # JSON parser
      networkmanagerapplet # Network manager tray icon
      nixfmt # A nix formatter
      pavucontrol # Sound manager
      polkit_gnome # Polkit manager
      ripgrep # Silver searcher grep
      rofi-wayland # App launcher
      slurp # Monitor selector
      swappy # Edit screenshots
      swaynotificationcenter # Notification daemon
      unzip # An extraction utility
      wdisplays # Displays manager
      wl-clipboard # Clipboard daemon
      wlogout # Logout screen
    ];

    etc = {
      "wlogout-icons".source = "${pkgs.wlogout}/share/wlogout/icons";
      "polkit-gnome".source = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      "kdeconnectd".source = "${pkgs.libsForQt5.kdeconnect-kde}/libexec/kdeconnectd";
    };
  };

  services = lib.mkIf config.desktop-environment.hyprland.enable {
    dbus.enable = true;
    gvfs.enable = true; # Needed for nautilus
  };

  security.polkit.enable = lib.mkIf config.desktop-environment.hyprland.enable true;
  services.gnome-keyring.enable = true;

  disabledModules = ["programs/hyprland.nix"]; # Needed for hyprland flake

  home-manager.sharedModules = [
    {
      programs.swaylock = {
        package = pkgs."swaylock-effects";
        settings = {
          show-keyboard-layout = true;
          daemonize = true;
          effect-blur = "5x2";
          clock = true;
          indicator = true;
          font-size = 25;
          indicator-radius = 85;
          indicator-thickness = 16;
          screenshots = true;
          fade-in = 1;
        };
      };

      xdg = {userDirs = {enable = true;};};
      xdg.configFile."hypr/hyprland.conf".text = ''
        # Basic functionalities
        exec-once = gnome-keyring-daemon --start
        exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
        exec-once = dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland
        exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec-once = sleep 2 && waybar & sleep 2 && hyprctl reload & /etc/polkit-gnome & swaync & hyprpaper & /etc/kdeconnectd & hyprland-per-window-layout
        # Tray applications
        exec-once = kdeconnect-indicator & clipman clear --all & wl-paste -t text --watch clipman store & nm-applet --indicator
        # Standard applications
        exec-once = warp & corectrl & firefox & signal-desktop & nautilus -w & nautilus -w & firefox --no-remote -P Element --name element https://icedborn.github.io/element-web https://discord.com/app & steam
        # Terminals/Task managers/IDEs
        exec-once = kitty --class startup-nvchad tmux new -s nvchad nvim & kitty --class startup-kitty tmux new -s terminals \; split-window -v \; select-pane -U \; split-window -h \; select-pane -D & kitty --class startup-monitor tmux new -s task-managers btop \; split-window -v nvtop

        ### MONITORS ###

        # You have to change this based on your monitor


        # See available monitors with 'hyprctl monitors'
        monitor=desc:Acer Technologies XZ322Q 1049010E43900,1920x1080@165,0x0,1
        workspace = 1, monitor:Acer Technologies XZ322Q 1049010E43900, default:true
        workspace = 2, monitor:Acer Technologies XZ322Q 1049010E43900
        workspace = 3, monitor:Acer Technologies XZ322Q 1049010E43900
        workspace = 4, monitor:Acer Technologies XZ322Q 1049010E43900
        workspace = 5, monitor:Acer Technologies XZ322Q 1049010E43900


        monitor=desc:Samsung Electric Company SAMSUNG 0x01000E00,2560x1440@60,1920x0,1
        workspace = 6, monitor:Samsung Electric Company SAMSUNG 0x01000E00, default:true
        workspace = 7, monitor:Samsung Electric Company SAMSUNG 0x01000E00
        workspace = 8, monitor:Samsung Electric Company SAMSUNG 0x01000E00


        #exec-once = hyprctl output create headless
        #monitor = HEADLESS-1,2560x1440@60,0x1080,1
        #workspace = 20, monitor:HEADLESS-1, default:true

        ### CONFIGURATION ###

        general {
        	border_size = 1
        	no_border_on_floating = false
        	gaps_in = 0
        	gaps_out = 0
        	col.inactive_border = rgb(000000)
        	col.active_border = rgb(505050)
        	layout = dwindle
          resize_on_border = true
        }

        decoration {
        	rounding = 5
        	blur_size = 3
        	blur_new_optimizations = true
        	drop_shadow = false
        }

        animations {
        	enabled = yes
        	bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        	animation = windows, 1, 7, myBezier
        	animation = windowsOut, 1, 7, default, popin 80%
        	animation = border, 1, 10, default
        	animation = fade, 1, 7, default
        	animation = workspaces, 1, 6, default
        }

        input {
        	follow_mouse = 1 # Focus mouse on other windows on hover but not the keyboard
        	force_no_accel = true
        }

        misc {
        	disable_hyprland_logo = true
        	disable_splash_rendering = true
        	vrr = 2
        }

        dwindle {
        	pseudotile = yes
        	preserve_split = yes
        }

        master {
        	new_is_master = true
        }

        ### KEYBINDINGS ###

        bind = SUPER, F1, exec, ~/.config/hypr/keybind
        bind = SUPERSHIFT, F, fullscreen,1

        $mod = SUPER

        # terminal, screen locking, launcher

        bind = $mod, t, exec, kitty
        bind = ALT, RETURN, exec, kitty --title fly_is_kitty
        bind = $mod, RETURN, exec, kitty --title kitty_term
        bindr = SUPER, SUPER_L, exec, nwg-drawer
        bind = $mod, L, exec, swaylock -f
        bind = $mod, R, exec, rofi -show drun
        bind = $mod SHIFT, E, exec, rofi-power-menu hyprland
        bind = $mod, Q, killactive,

        # screenshots
        $screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast save area - | swappy -f -; hyprctl keyword animation "fadeOut,1,4,default"
        bind = , INS, exec, grimblast save output - | swappy -f -
        bind = SHIFT, INS, exec, grimblast save active - | swappy -f -
        bind = ALT, INS, exec, $screenshotarea

        # media controls
        bindl = , XF86AudioPlay, exec, playerctl play-pause
        bindl = , XF86AudioPrev, exec, playerctl previous
        bindl = , XF86AudioNext, exec, playerctl next

        # volume
        bindle = , XF86AudioRaiseVolume, exec, volumectl -u up
        bindle = , XF86AudioLowerVolume, exec, volumectl -u down
        bindl = , XF86AudioMute, exec, volumectl -u toggle-mute
        bindl = , XF86AudioMicMute, exec, volumectl -m toggle-mute
        bind = , Pause, exec, volumectl -m toggle-mute
        bind = $mod, V, exec, pavucontrol

        # backlight
        bindle = , XF86MonBrightnessUp, exec, lightctl up
        bindle = , XF86MonBrightnessDown, exec, lightctl down

        # apps
        bind = $mod, grave, exec, 1password --quick-access
        bind = $mod, C, exec, clipman pick -t rofi -T='-p Clipboard'
        bind = $mod, D, exec, thunar

        # window controls
        bind = $mod, F, fullscreen,
        bind = $mod, Space, togglefloating,
        bind = $mod SHIFT, Space, workspaceopt, allfloat
        bind = $mod, A, togglesplit,

        # override the split direction for the next window to be opened
        bind = $mod, V, layoutmsg, preselect d
        bind = $mod, H, layoutmsg, preselect r

        # group management
        bind = $mod, G, togglegroup,
        bind = $mod SHIFT, G, moveoutofgroup,
        bind = ALT, left, changegroupactive, b
        bind = ALT, right, changegroupactive, f
        bind = $mod, tab, changegroupactive, f
        bind = SUPER SHIFT, left, moveintogroup, l
        bind = SUPER SHIFT, right, moveintogroup, r
        bind = SUPER SHIFT, up, moveintogroup, u
        bind = SUPER SHIFT, down, moveintogroup, d

        # move focus
        bind = $mod, left, movefocus, l
        bind = $mod, right, movefocus, r
        bind = $mod, up, movefocus, u
        bind = $mod, down, movefocus, d

        # move window
        bind = $mod SHIFT, left, movewindow, l
        bind = $mod SHIFT, right, movewindow, r
        bind = $mod SHIFT, up, movewindow, u
        bind = $mod SHIFT, down, movewindow, d

        # Move/resize windows with mainMod + LMB/RMB and dragging << most beautiful way to interact with windows...floating or not!! TRY IT!!!! (if you have the back and forward side mouse buttons)
        bindm = , mouse:276, movewindow # here be magic
        bindm = , mouse:275, resizewindow # with a sprinkle of dragons
        bindm = $mod, mouse:272, movewindow
        bindm = $mod, mouse:273, resizewindow

        # navigate workspaces
        bind = $mod, 1, workspace, 1
        bind = $mod, 2, workspace, 2
        bind = $mod, 3, workspace, 3
        bind = $mod, 4, workspace, 4
        bind = $mod, 5, workspace, 5
        bind = $mod, 6, workspace, 6
        bind = $mod, 7, workspace, 7
        bind = $mod, 8, workspace, 8
        bind = $mod, 9, workspace, 9

        # move window to workspace
        bind = $mod SHIFT, 1, movetoworkspace, 1
        bind = $mod SHIFT, 2, movetoworkspace, 2
        bind = $mod SHIFT, 3, movetoworkspace, 3
        bind = $mod SHIFT, 4, movetoworkspace, 4
        bind = $mod SHIFT, 5, movetoworkspace, 5
        bind = $mod SHIFT, 6, movetoworkspace, 6
        bind = $mod SHIFT, 7, movetoworkspace, 7
        bind = $mod SHIFT, 8, movetoworkspace, 8
        bind = $mod SHIFT, 9, movetoworkspace, 9

        ### APPS ###

        # Move apps to workspaces
        windowrulev2 = workspace 1 silent, class:^(firefox)$
        windowrulev2 = workspace 2 silent, class:^(startup-nvchad)$
        windowrulev2 = workspace 3 silent, class:^(Steam|steam|steam_app_.*)$, title:^((?!notificationtoasts.*).)*$
        windowrulev2 = workspace 3 silent, title:^(.*Steam[A-Za-z0-9\s]*)$
        windowrulev2 = workspace 11 silent, class:^(WebCord|Signal|element)$
        windowrulev2 = workspace 12 silent, class:^(org\.gnome\.Nautilus)$
        windowrulev2 = workspace 13 silent, class:^(app.drey.Warp)$
        windowrulev2 = workspace 14 silent, class:^(startup-monitor|corectrl)$ # btop
        windowrulev2 = workspace 15 silent, class:^(startup-kitty)$ # Terminal

        # Maximize apps
        windowrulev2 = maximize, class:^(firefox|startup-nvchad|Steam|startup-kitty|startup-monitor)$, floating:0
        windowrulev2 = maximize, title:^(Steam)$
        windowrulev2 = noborder, fullscreen:1 # Hide maximized window borders

        # Tile apps
        windowrulev2 = tile, class:^(Godot.*|Steam|steam_app_.*|photoshop\.exe)$
        windowrulev2 = tile, title:^(.*Steam[A-Za-z0-9\s]*)$

        # Float apps
        windowrulev2 = float, class:^(feh)$

        # Pin floating apps
        windowrulev2 = pin, class:^(feh)$

        # Hide apps
        windowrulev2 = float, title:^(Firefox — Sharing Indicator|Wine System Tray)$
        windowrulev2 = size 0 0, title:^(Firefox — Sharing Indicator|Wine System Tray)$

        # Remove initial focus from apps
        windowrulev2 = noinitialfocus, class:^(steam)$, title:^(notificationtoasts.*)$, floating:1
      '';
    }
  ];
}
