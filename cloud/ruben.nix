{ config, lib, pkgs, modulesPath, ... }: {

	imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

	boot = {
		loader.grub = {
			efiSupport = true;
			efiInstallAsRemovable = true;
			device = "nodev";
		};

		initrd = {
			kernelModules = [ "nvme" ];
			availableKernelModules = [ 
				"ata_piix" 
				"uhci_hcd"
				"xen_blkfront"
			];
		};
		tmp.cleanOnBoot = true;
	};
	zramSwap.enable = true;

	fileSystems = {
		"/" = {
			device = "/dev/sda1";
			fsType = "ext4";
		};

		"/boot" = {
			device = "/dev/disk/by-uuid/EECB-6A11";
			fsType = "vfat";
		};
	};

	networking = {
		hostName = "klaus";
		domain = "";
	};

	services = {
		k3s = {
			enable = false;
			role = "server";
			token = "%";
			serverAddr = "https://10.0.20.182:6443";
			extraFlags = toString [
				"--node-ip 10.0.10.247"
				"--node-name ruben"
				"--disable traefik"
				"--container-runtime-endpoint unix:///run/containerd/containerd.sock"
			];
		};

		headscale = {
			enable = true;
			address = "10.0.10.247";
			port = 5080;
			user = "paul";
			group = "users";
			settings = {
				server_url = "http://10.0.10.247:5080";
				db_type = "sqlite3";
				dns_config = {
					nameservers = [
						"1.1.1.1"
						"1.0.0.1"
					];
				};
			};
		};
	};
}
