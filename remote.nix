{lib, pkgs, ... }:
{
	users.users.paul = {
		openssh.authorizedKeys.keys = [];
	};

	environment.systemPackages = with pkgs; [
		tailscale		
		rsync
	];

	services = {
		openssh = {
			enable = true;
			settings = lib.mkDefault {
				PermitRootLogin = "no";
			};
		};

		tailscale = lib.mkDefault {
			enable = true;
			port = 0;
			interfaceName = "tailtun";
		};
	};
}
