{ lib, pkgs, ... }:
{

	networking = {
		networkmanager.enable = true;
		extraHosts = ''10.30.65.216 tiny'';
		
		firewall.enable = false;
		#firewall = {
		#	allowedTCPPorts = [];
		#	allowedUDPPorts = [];
		#};
	};
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
}
