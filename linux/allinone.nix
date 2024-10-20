{ config, pkgs, lib, hyprland, ... }:
let
	feather = pkgs.callPackage ./fonts/feather/default.nix {};

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

in {

	time.timeZone = "Europe/London";

	nix.gc = lib.mkDefault {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 60d";
	};
	nixpkgs.config.allowUnfree = true;

	boot = {
		loader.grub = {
			enable = true;
			device = "/dev/sdd";
		};
		
		initrd = {
			kernelModules = [];
			availableKernelModules = [ 
				"xhci_pci" 
				"ahci" 
				"usbhid" 
				"usb_storage" 
				"sd_mod" 
				"nvidia"
				"nvidia_modeset"
				"nvidia_uvm"
				"nvidia_drm"
			];
		};
		kernel = {
			sysctl = {
				"vm.max_map_count" = 1000000;				
			};
		};
		kernelParams = [ "nvidia_drm.modeset=1" ];
		tmp.useTmpfs = true;
		extraModprobeConfig = "options kvm_amd nested=1";
	};

## Fstab
	fileSystems."/" = { 
		device = "/dev/disk/by-uuid/afe9d9ac-f4e2-479c-a82f-d49e4534627a";
		fsType = "btrfs";
		options = [
			"defaults"
			"rw"
			"noatime"
			"compress=zstd:1"
			"commit=120"
			"ssd"
		];
	};

	fileSystems."/boot" = { 
		device = "/dev/disk/by-uuid/3BE5-B22E";
		fsType = "vfat";
		options = [
			"defaults"
			"noatime"
		];
	};

	fileSystems."/home" = { 
		device = "/dev/disk/by-uuid/0b7fc639-1d72-4c49-97d1-3b59f3ea9418";
		fsType = "ext4";
		options = [
			"defaults"
			"rw"
			"noatime"
		];
	};

	fileSystems."/mnt/archhdd" = { 
		device = "/dev/disk/by-uuid/3bd74e62-e0ef-4ed5-adbf-c499fa9b425d";
		fsType = "ext4";
		options = [
			"defaults"
			"noatime"
			"commit=120"
		];
	};
	swapDevices = [ ];

	hardware = {
		bluetooth.enable = true;
		opengl = {
			enable = true;
			driSupport = true;
			driSupport32Bit = true;
		};
		nvidia = {
			package = config.boot.kernelPackages.nvidiaPackages.stable;
			nvidiaSettings = true;
			powerManagement.enable = false;
		};
		cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	};

	environment = {
		shells = [ pkgs.fish ];

		variables = {
			EDITOR = "nvim";
			VISUAL = "nvim";
			GDK_SCALE = "2";
			GDK_DPI_SCALE = "0.5";
			_JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";

			WLR_NO_HARDWARE_CURSORS = "1";
			SDL_VIDEODRIVER="wayland";
		};

		sessionVariables = {
			STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
			WLR_NO_HARDWARE_CURSORS = "1";
		};

		etc = {
			"modprobe.d/blacklist_i2c-nvidia-gpu.conf".text = ''blacklist i2c_nvidia_gpu''; 
		};

		systemPackages = with pkgs; [
			htop
			nnn
			fff
			mpv
			flatpak
			openvswitch
			mininet
			glibc
			cmake
			openssl
			dbus
			tor
			tor-browser-bundle-bin
			libguestfs
			virt-manager
			psmisc
			libcxx

			#Wayland-ui
			alacritty
			dbus-sway-environment
			configure-gtk
			wayland
			xdg-utils
			glib
			dracula-theme
			gnome3.adwaita-icon-theme
			sway
			swaylock
			swayidle
			grim
			slurp
			wl-clipboard
			bemenu
			mako
			wdisplays
			wofi
			wofi-emoji
			waybar
			qt6.qtwayland

			#Extra
			glxinfo
			vulkan-tools
			glmark2

			# Previous Config
			#rofi
			breeze-gtk
			capitaine-cursors
			qogir-theme

			#Configuration
			neovim
			pinentry
		];
	};



	users = {
		defaultUserShell = pkgs.fish;
		extraGroups.vboxusers.members = [ "paul" ];

		users = {

			paul = {
				initialPassword = "password123";
				isNormalUser = true;
				shell = pkgs.fish;
				extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
				subUidRanges = [
					{ count = 65534; startUid = 100001; }
				];
				subGidRanges = [
					{ count = 65534; startGid = 100001; }
				];
			};

			sophia = {
				initialPassword = "joseph3695";
				isNormalUser = true;
				shell = pkgs.fish;
				extraGroups = [];
			};
		};
	};

	security.polkit.enable = true;

	xdg.portal = {
		enable = true;
		wlr.enable = true;
		extraPortals = with pkgs; [
			xdg-desktop-portal-wlr
			xdg-desktop-portal-gtk
		];
	};

	services = {
		dbus.enable = true;
		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
		};

		flatpak.enable = true;
		trezord.enable = true;
		xserver = {
			videoDrivers = [ "nvidia" ];
			dpi = 185;
			displayManager.gdm = {
				wayland = true;
			};
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

	programs = {
		hyprland = {
			enable = true;
			xwayland.enable = true;
			xwayland.hidpi = true;
			nvidiaPatches = true;
		};
		## Steam!
		steam = {
			enable = true;
			remotePlay.openFirewall = true;
			dedicatedServer.openFirewall = true;
			gamescopeSession = {
				enable = true;
				#args = [];
				#env = {};
			};
		};
		gamemode.enable = true;
		fish.enable = true;
	};

	virtualisation = {

		podman = {
			enable = true;
			dockerCompat = true;
			enableNvidia = true;
			defaultNetwork.settings.dns_enabled = true;
		};

		virtualbox = {
			host.enable = true;
			host.enableExtensionPack = true;
			guest.enable = true;
			guest.x11 = true;
		};

		libvirtd = {
			enable = true;
		};
		
		vswitch = {
			enable = true;
		};
	};

	networking = {
		hostName = "nixtower";
		useDHCP = lib.mkDefault true;
		networkmanager.enable = true;
		extraHosts = ''10.30.65.216 tiny'';
	};


	fonts.fonts = with pkgs; [
		source-code-pro
		feather
		material-icons
		fira
		fira-code
		fira-code-symbols
		(nerdfonts.override { fonts = [ "Iosevka" ]; })
	];
	fonts.fontDir.enable = true;

	system.stateVersion = "22.05"; # Did you read the comment?

}
