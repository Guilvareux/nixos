{ config, lib, pkgs, modulesPath, ... }:
{
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
	
	services.k3s = {
		enable = true;
		role = "agent";
		token = "%";
		serverAddr = "https://10.0.20.182:6443";
		extraFlags = toString [
			"--node-ip 10.0.20.222"
			"--node-name herman"
			"--container-runtime-endpoint unix:///run/containerd/containerd.sock"
		];

	};
}
