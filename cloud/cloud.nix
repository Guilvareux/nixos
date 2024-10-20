{ config, pkgs, lib, ... }:

{
	## Nix Settings
	nix = {
		package = pkgs.nixUnstable;
		extraOptions = ''
		experimental-features = nix-command flakes
		'';

		settings.experimental-features = [ "nix-command" "flakes" ];
	};
	nixpkgs.config.allowUnfree = true;

	time.timeZone = lib.mkDefault "Europe/London";
	users.defaultUserShell = pkgs.fish;

	environment.shells = with pkgs; [ fish ];
	environment.variables.EDITOR = "nvim";

	users.users.paul = {
		initialPassword = "password123";		
		isNormalUser = true;
		shell = pkgs.fish;
		extraGroups = [ "wheel" ];
		openssh.authorizedKeys.keys = [];
		packages = with pkgs; [
			starship
			direnv
			just
		];
	};

	environment.systemPackages = with pkgs; [
		vim
		neovim
		wget
		curl
		htop
		unzip
		neovim
		git
		tmux
		fish
		gnupg
		gcc
		glibc
		cmake
		rustup
		podman
		openssl
		pkg-config
		k3s
		iptables
		headscale
	];

	fonts.fontDir.enable = true;
	networking.firewall.enable = false;
	networking.nameservers = [
		"1.1.1.1"
		"1.0.0.1"
	];
	programs.fish.enable = true;
	#networking.firewall.allowedTCPPorts = [ 22 80 443 6443 ];
	security.polkit.enable = true;
	virtualisation = {
		containerd = {
			enable = true;
			settings = {
				version = 2;
				plugins."io.containerd.grpc.v1.cri" = {
					cni.conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
					cni.bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
						mkdir -p $out
						ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
					''}";
				};
			};
		};
	};

	systemd.services.k3s = {
		wants = ["containerd.service"];			
		after = ["containerd.service"];			
	};
}
