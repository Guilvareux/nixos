{ lib, pkgs, inputs, ... }:

let
	dbus-sway-environment = pkgs.writeTextFile {
		name = "dbus-sway-environment";
		destination = "/bin/dbus-sway-environment";
		executable = true;

		text = ''
		dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
		systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
		systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
		  '';
	};

	configure-gtk = pkgs.writeTextFile {
		name = "configure-gtk";
		destination = "/bin/configure-gtk";
		executable = true;
		text = let
			schema = pkgs.gsettings-desktop-schemas;
			datadir = "${schema}/share/gsettings-schemas/${schema.name}";
		in ''
			export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
			gnome_schema=org.gnome.desktop.interface
			gsettings set $gnome_schema gtk-theme 'Dracula' 
			'';
	};

in
{

	boot = {
		initrd = {
			availableKernelModules = [ 
				"nvidia"
				"nvidia_modeset"
				"nvidia_uvm"
				"nvidia_drm"
			];
		};
		kernelParams = [ "nvidia_drm.modeset=1" ];
	};

	xdg.portal = lib.mkForce {
		enable = true;
		config.common.default = "*";
		wlr.enable = true;
		extraPortals = with pkgs; [
			xdg-desktop-portal-gtk
		];
	};

	services = {
		dbus.enable = true;
		xserver = {
			enable = lib.mkForce false;
			displayManager = lib.mkForce {
				gdm = {
					enable = false;
					wayland = true;
				};
			};
			windowManager = lib.mkForce {};
			extraConfig = ''
				Section "Device"
					Identifier     "Device0"
					Driver         "nvidia"
					VendorName     "NVIDIA Corporation"
					BoardName      "NVIDIA GeForce RTX 2080 SUPER"
					Option		   "Coolbits" "28"
					#Option         "TripleBuffer" "on"
				EndSection
			'';
		};
	}; 

	## General Env
	environment = {

		variables = {
			WLR_NO_HARDWARE_CURSORS = "1";
			SDL_VIDEODRIVER="wayland";
			LIBVA_DRIVER_NAME="nvidia";
			XDG_SESSION_TYPE="wayland";
			GBM_BACKEND = "nvidia-drm";
			__GLX_VENDOR_LIBRARY_NAME="nvidia";
			WLR_DRM_NO_ATOMIC = "1";
		};

		systemPackages = with pkgs; [
			#NixOS Wiki
			dbus-sway-environment
			configure-gtk
			wayland
			xdg-utils
			glib
			gnome3.adwaita-icon-theme
			grim
			slurp
			wl-clipboard
			bemenu
			mako
			wdisplays
			rofi-wayland
			qt6.qtwayland
		];
	};

	programs = {
		hyprland = {
			enable = true;
			xwayland.enable = true;
		};
		waybar = {
			enable = true;
		};
	};
}
