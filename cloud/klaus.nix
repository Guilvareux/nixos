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
			device = "/dev/disk/by-uuid/4D96-3CE6";
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
			extraFlags = toString [
				"--node-ip 10.0.20.56"
				"--node-name klaus"
				"--disable traefik"
				"--container-runtime-endpoint unix:///run/containerd/containerd.sock"
				"--cluster-init"
			];

		};
	};
}
