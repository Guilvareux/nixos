# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

	boot.loader.systemd-boot.enable = true;
	boot.loader.grub.enable = false;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.efi.efiSysMountPoint = "/boot/efi";
	boot.initrd.secrets = {
		"/crypto_keyfile.bin" = null;
	};
	boot.initrd.luks.devices."luks-2f537715-e701-4c30-b564-c7cae7de3c3c".device = "/dev/disk/by-uuid/2f537715-e701-4c30-b564-c7cae7de3c3c";
	boot.initrd.luks.devices."luks-2f537715-e701-4c30-b564-c7cae7de3c3c".keyFile = "/crypto_keyfile.bin";

	boot.extraModprobeConfig = "options kvm_amd nested=1";
	boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];

	fileSystems."/" =
	{ device = "/dev/disk/by-uuid/e4d806c3-9ca3-4dc1-9975-fcecb6354ca0";
	  fsType = "ext4";
	};

	boot.initrd.luks.devices."luks-d0c990da-0187-4112-a7cf-fa23b10adf79".device = "/dev/disk/by-uuid/d0c990da-0187-4112-a7cf-fa23b10adf79";

	fileSystems."/boot/efi" =
	{ device = "/dev/disk/by-uuid/3DBB-86F8";
	  fsType = "vfat";
	};

	swapDevices =
	[ { device = "/dev/disk/by-uuid/61b317f8-e558-4056-9d87-5a4e9be37404"; }
	];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
	networking.useDHCP = lib.mkDefault true;
	networking.hostName = "nixnuc"; # Define your hostname.
	# networking.interfaces.eno1.useDHCP = lib.mkDefault true;

	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
	services.xserver.displayManager.gdm.autoSuspend = false;
	hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

	services.xserver.videoDrivers = [ "intel" ];
}
