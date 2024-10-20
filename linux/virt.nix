{ pkgs, lib, ... }:
{

	environment.systemPackages = with pkgs; [
		openvswitch
		libguestfs
		qemu_kvm
		virt-manager
		#mininet
		psmisc
		libcxx
	];

	virtualisation = {

		#containers = {
		#	cdi.dynamic.nvidia.enable = true;			
		#};

		podman = {
			enable = true;
			dockerCompat = lib.mkDefault true;
			defaultNetwork.settings.dns_enabled = true;
		};

		virtualbox = {
			host.enable = true;
			host.enableExtensionPack = true;
			guest.enable = true;
			#guest.x11 = true;
		};

		libvirtd = {
			enable = true;
		};
		
		vswitch = {
			enable = true;
		};
	};
}
