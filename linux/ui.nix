{ pkgs, lib, ... }:
let 
	polybarwithi3 = pkgs.polybar.override {
		i3Support = true;
	};
in {

	environment = {
		variables = {
			GDK_SCALE = "2";
			GDK_DPI_SCALE = "0.5";
			_JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
		};

		sessionVariables = {
			STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
		};


		etc = {
			"modprobe.d/blacklist_i2c-nvidia-gpu.conf".text = ''blacklist i2c_nvidia_gpu''; 
		};


		systemPackages = with pkgs; [
			#i3
			#polybarwithi3
			#rofi
			#picom
			#lxappearance
			alacritty
			breeze-gtk
			capitaine-cursors
			qogir-theme
			tor
			tor-browser-bundle-bin
			pinentry
			mpv
			vulkan-tools
			glxinfo
			glmark2
		];
	};

	services = {
		displayManager = {
			defaultSession = "none+i3";
		};
		xserver = {
			enable = lib.mkDefault true;
			displayManager = lib.mkDefault {
				#defaultSession = "none+i3";
				gdm = {
					enable = true;
				};
			};

			windowManager = lib.mkDefault {
				i3 = {
					enable = true;
					package = pkgs.i3;
				};
			};

			xkb.layout = "us";
		};

		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
		};
		trezord.enable = true;
	};
}
