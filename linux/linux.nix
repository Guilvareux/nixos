{ pkgs, lib, ... }:
let

	feather = pkgs.callPackage ../fonts/feather/default.nix {};
in {
	nix = {
		extraOptions = lib.mkDefault ''
		experimental-features = nix-command flakes
		keep-outputs = true
		keep-derivations = true
		'';

		settings.experimental-features = [ "nix-command" "flakes" ];
		settings.auto-optimise-store = lib.mkDefault true;
	};
	nixpkgs.config.allowUnfree = true;

	users = {
		defaultUserShell = pkgs.nushell;

		users = {
			paul = {
				initialPassword = "password123";
				isNormalUser = true;
				shell = pkgs.nushell;
				extraGroups = [ "wheel" "libvirtd" ];
				subUidRanges = [
					{ count = 65534; startUid = 100001; }
				];
				subGidRanges = [
					{ count = 65534; startGid = 100001; }
				];
			};
			sophia = {
				initialPassword = "password123";
				isNormalUser = true;
				shell = pkgs.nushell;
				extraGroups = [];
			};
		};
		extraGroups.vboxusers.members = [ "paul" ];
	};


	xdg.portal = lib.mkDefault {
		enable = true;
		config.common.default = "*";
		extraPortals = with pkgs; [
			xdg-desktop-portal-gtk
		];
	};

	services = {
		flatpak.enable = true;
	};

	programs = {
		fish.enable = true;
		virt-manager.enable = true;
	};

	environment = {
		systemPackages = with pkgs; [
			vim
			neovim
			ntfs3g
		];
		shells = [ pkgs.zsh pkgs.fish pkgs.nushell ];
		variables = {
			EDITOR = "nvim";
			VISUAL = "nvim";
		};
	};

	security = {
		polkit.enable = true;
		sudo.enable = true;
	};

	fonts.packages = with pkgs; [
		feather
		source-code-pro
		material-icons
		fira
		fira-code
		fira-code-symbols
		(nerdfonts.override { fonts = [ "Iosevka" ]; })
	];
	fonts.fontDir.enable = true;
}
