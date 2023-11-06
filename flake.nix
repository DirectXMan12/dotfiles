{
	description = "Home Manager configuration of directxman12";

	inputs = {
		# Specify the source of Home Manager and Nixpkgs.
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		alacritty-apply = {
			url = "github:directxman12/alacritty-apply";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, home-manager, ... }@inputs:
		let
			system = "x86_64-linux";
			pkgs = nixpkgs.legacyPackages.${system};
		in {
			homeConfigurations."directxman12" = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;

				extraSpecialArgs = {
					alacritty-apply = inputs.alacritty-apply;
				};

				# Specify your home configuration modules here, for example,
				# the path to your home.nix.
				modules = [
				 ({config, pkgs, ...}: { nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
						 "google-chrome-dev"
						 "obsidian"
					 ];
				 })
				 ./home.nix
				];

				# Optionally use extraSpecialArgs
				# to pass through arguments to home.nix
			};
		};
}
