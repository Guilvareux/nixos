{ pkgs, lib, ... }:
{

	environment = {
		sessionVariables = {
			STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
		};
	};


	programs = {
		## Steam!
		steam = {
			enable = true;
			remotePlay.openFirewall = true;
			dedicatedServer.openFirewall = true;
			gamescopeSession = {
				enable = true;
				#args = [];
				#env = {};
			};
		};
		gamemode.enable = true;
	};

	#environment.systemPackages = with pkgs; [
		
	#];
}
