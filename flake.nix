{
	description = "Guilvareux's Systems";

	inputs = {
		hyprland.url = "github:hyprwm/Hyprland";
		utils.url = "flake-utils";
		nixpkgs.url = "nixpkgs";
		nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
		darwin.url = "nix-darwin";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, darwin, hyprland, ... } @inputs:
	let
		linux =			./linux/linux.nix;
		nixtower =		./linux/nixtower.nix;
		ui =			./linux/ui.nix;
		networking =	./linux/networking.nix;
		gaming =		./linux/gaming.nix;
		virt =			./linux/virt.nix;
		wayland =		./linux/wayland.nix;
		remote =		./remote.nix;
		woodford =		./woodford.nix;
		brainiac =		./cloud/brainiac.nix;
		k3s =			./linux/k3s.nix;

	in {
		nixosConfigurations = {

			nixtower = let
				pkgs = nixpkgs;
			in
				pkgs.lib.nixosSystem {
					system = "x86_64-linux";
					modules = [ 
						linux
						nixtower
						ui
						networking
						gaming
						virt
					];
				};

			nixtower-wayland = let
				pkgs = nixpkgs;
				hypl = hyprland;
			in
				pkgs.lib.nixosSystem {
					system = "x86_64-linux";
					modules = [ 
						linux
						nixtower
						ui
						wayland 
						remote
						networking
						gaming
						virt
					];
					specialArgs = { inherit inputs; };
				};

			nixnuc = let
				pkgs = nixpkgs;
			in
				pkgs.lib.nixosSystem {
					system = "x86_64-linux";
					modules = [
						linux
						./linux/nixnuc.nix
						networking
						ui
						virt
						remote
					];
				};

			klaus = let
				pkgs = nixpkgs;
			in
				pkgs.lib.nixosSystem {
					system = "aarch64-linux";
					modules = [ 
						linux
						remote
						k3s
						./cloud/klaus.nix
					];
				};

			herman = let
				pkgs = nixpkgs;
			in
				pkgs.lib.nixosSystem {
					system = "x86_64-linux";
					modules = [
						linux
						remote
						k3s
						./cloud/herman.nix
					];
				};

			ruben = let
				pkgs = nixpkgs;
			in
				pkgs.lib.nixosSystem {
					system = "x86_64-linux";
					modules = [
						linux
						remote
						k3s
						./cloud/ruben.nix
					];
				};

			brainiac = let
				pkgs = nixpkgs;
			in
				pkgs.lib.nixosSystem {
					system = "x86_64-linux";
					modules = [ 
						{
							time.timeZone = pkgs.lib.mkOverride 500 "Europe/Amsterdam";
						}
						linux
						brainiac
						virt
						remote
					];
				};
		};

		darwinConfigurations = {
			MacLap = darwin.lib.darwinSystem {
				system = "x86_64-darwin";
				modules = [ 
					./darwin/darwin.nix
				];
			};
			Admins-MacBook-Pro-4 = darwin.lib.darwinSystem {
				system = "x86_64-darwin";
				modules = [ 
					./darwin/darwin.nix
				];
			};
		};
	};
}
