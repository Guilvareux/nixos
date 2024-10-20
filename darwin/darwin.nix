{ config, pkgs, lib, ... }:

{
	config = {

		nix.extraOptions = lib.mkOverride 500 ''
		experimental-features = nix-command flakes
		keep-outputs = false
		keep-derivations = false
		keep-failed = false
		'';

		time.timeZone = "Europe/London";

		users.users.paul = {
			#shell = "${pkgs.fish}/bin/fish";
			shell = "${pkgs.nu}/bin/nu";
			createHome = true;
		};
		nixpkgs.config.allowUnfree = true;

		nix.gc = lib.mkOverride 1000 {
			automatic = false;
			interval = {
				Hour = 24;
				Minute = 0;
			};
			options = "--delete-older-than 30d";
		};


		nix.settings = {
			allowed-users = [
				"@admin"
				"paul"
			];
			auto-optimise-store = lib.mkOverride 500 false;
		};

		# Set login shell to fish
		#environment.loginShell = "${pkgs.fish}/bin/fish";

		#system.keyboard.enableKeyMapping = true;


		environment.systemPackages = with pkgs; [
			vim
			neovim
			teams
			vscodium
			xcode-install
			#xorg.xorgserver
			#xquartz
			rectangle
			iterm2
		];

		homebrew = {
			enable = true;
			caskArgs = {
				no_quarantine = true;
			};
			casks = [
				"altserver"
				"amethyst"
				"brave-browser"
				"desmume"
				"devdocs"
				"discord"
				"ferdium"
				"font-fira-code"
				"font-source-code-pro"
				"freetube"
				"gimp"
				"google-chrome"
				"iterm2"
				"jellyfin-media-player"
				"kodi"
				"libreoffice"
				"librewolf"
				"logseq"
				"megasync"
				"obsidian"
				"openscad"
				"osxfuse"
				"protege"
				"protonvpn"
				"raven-reader"
				"thunderbird"
				"todoist"
				"tor-browser"
				"vagrant"
				"vivaldi"
				"xquartz"
				"zotero"
			];

			taps = [
				"homebrew/bundle"
				"homebrew/cask"
				"homebrew/cask-fonts"
				"homebrew/cask-versions"
				"homebrew/core"
				"homebrew/services"
				"kryptco/tap"
				"nanovms/ops"
				"nanovms/qemu"
				"osx-cross/arm"
				"osx-cross/avr"
				"qmk/qmk"
				"zegervdv/zathura"
			];

			brews = [
				"glib"
				"harfbuzz"
				"librsvg"
				"pinentry"
				"gnupg"
				"blackbox"
				"ca-certificates"
				"cmake"
				"coreutils"
				"expect"
				"fff"
				"shared-mime-info"
				"imagemagick"
				"iperf"
				"latexindent"
				"libnotify"
				"libslirp"
				"meson"
				"mono"
				"nghttp2"
				"pinentry-mac"
				"poppler"
				"qt"
				"subversion"
				"watch"
				"kryptco/tap/kr"
				"qmk/qmk/qmk"
				{
					name = "zegervdv/zathura/girara";
					args = ["HEAD"];
				}
				"zegervdv/zathura/synctex"
				{
					name = "zegervdv/zathura/zathura";
					args = ["HEAD"];
				}
				"zegervdv/zathura/zathura-pdf-poppler"
			];
		};

		services.nix-daemon.enable = true;
	};	
	
}
