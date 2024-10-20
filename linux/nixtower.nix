{ config, lib, pkgs, ... }:
{

	nix = {
		gc = lib.mkDefault {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 60d";
		};
		settings = {
			substituters = [
				"https://cuda-maintainers.cachix.org"
			];
			trusted-public-keys = [
				"cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
			];
		};
	};

	time.timeZone = lib.mkDefault "Europe/London";
	i18n.defaultLocale = "en_GB.utf8";
	boot = {
		loader.systemd-boot.enable = true;
		loader.efi.canTouchEfiVariables = true;
		loader.efi.efiSysMountPoint = "/boot/efi";
		
		initrd = {
			kernelModules = [];
			availableKernelModules = [ 
				"xhci_pci" 
				"ahci" 
				"usbhid" 
				"usb_storage" 
				"sd_mod" 
			];
		};
		kernel = {
			sysctl = {
				"vm.max_map_count" = 1000000;				
			};
		};
		tmp.useTmpfs = true;
		extraModprobeConfig = "options kvm_amd nested=1";
	};

	fileSystems."/" = { 
		device = "/dev/disk/by-uuid/a4db48c8-40ce-4f80-9c57-36a34eebfef5";
		fsType = "btrfs";
		options = [
			"defaults"
			"rw"
			"noatime"
			"compress=zstd:1"
			"commit=120"
			"ssd"
			"subvol=@"
		];
	};

	fileSystems."/boot/efi" = {
		device = "/dev/disk/by-uuid/2352-C532";
		fsType = "vfat";
	};

	fileSystems."/home" = { 
		device = "/dev/disk/by-uuid/b6c79ff7-3db2-4177-b733-336da5c8fd77";
		fsType = "btrfs";
		options = [
			"defaults"
			"rw"
			"noatime"
			"nofail"
		];
	};

	fileSystems."/mnt/archhdd" = { 
		device = "/dev/disk/by-uuid/3bd74e62-e0ef-4ed5-adbf-c499fa9b425d";
		fsType = "ext4";
		options = [
			"defaults"
			"noatime"
			"commit=120"
			"nofail"
		];
	};
	swapDevices = [ 
		{device = "/dev/sda2";} 
	];

	hardware = {
		bluetooth.enable = true;
		opengl = {
			enable = true;
			driSupport32Bit = true;
			extraPackages = with pkgs; [
				vaapiVdpau
				libvdpau-va-gl
				nvidia-vaapi-driver
			];
		};
		nvidia = {
			nvidiaSettings = true;
			powerManagement.enable = true;
			open = false;
		};
		nvidia-container-toolkit.enable = true;
		cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	};

	networking = {
		useDHCP = lib.mkDefault true;
		hostName = "nixtower";
	};

	services = {
		xserver = {
			videoDrivers = [ "nvidia" ];
			dpi = 185;
		};

		openssh.settings = lib.mkForce {
			PermitRootLogin = "no";
		};

		tailscale = lib.mkForce {
			enable = true;
			port = 0;
			interfaceName = "tailtun";
		};
	}; 

	system.stateVersion = "22.05";
}
