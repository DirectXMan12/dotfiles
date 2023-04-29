{ config, pkgs, ... }:

{
	# load separate files
	imports = [
		./neovim.nix
	];

	# Home Manager needs a bit of information about you and the paths it should
	# manage.
	home.username = "directxman12";
	home.homeDirectory = "/home/directxman12";

	# This value determines the Home Manager release that your configuration is
	# compatible with. This helps avoid breakage when a new Home Manager release
	# introduces backwards incompatible changes.
	#
	# You should not change this value, even if you update Home Manager. If you do
	# want to update the value, then make sure to first check the Home Manager
	# release notes.
	home.stateVersion = "22.11"; # Please read the comment before changing.

	# The home.packages option allows you to install Nix packages into your
	# environment.
	home.packages = with pkgs; [
		# nerdfonts, but just dejavu
		(pkgs.nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })

		zsh
		nushell
		tree
		# google-chrome-dev # moving to system level to match pipewire?

		# # You can also create simple shell scripts directly inside your
		# # configuration. For example, this adds a command 'my-hello' to your
		# # environment:
		# (pkgs.writeShellScriptBin "my-hello" ''
		#		echo "Hello, ${config.home.username}!"
		# '')
	];

	# Home Manager is pretty good at managing dotfiles. The primary way to manage
	# plain files is through 'home.file'.
	home.file = {
		".zshrc".source = dotfiles/zshrc;

		# # You can also set the file content immediately.
		# ".gradle/gradle.properties".text = ''
		#		org.gradle.console=verbose
		#		org.gradle.daemon.idletimeout=3600000
		# '';
	};

	# (and for .config dirs)
	xdg.configFile = {
		"sway/config".source = dotfiles/sway/config;
		"tofi/config".source = dotfiles/tofi/config;

		"waybar/config".source = dotfiles/waybar/config;
		"waybar/style.css".source = dotfiles/waybar/style.css;

		"alacritty/alacritty.yml".source = dotfiles/alacritty/alacritty.yml;
		"alacritty/solarized-dark-custom.yml".source = dotfiles/alacritty/solarized-dark-custom.yml;
	};

	# You can also manage environment variables but you will have to manually
	# source
	#
	#  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
	#
	# or
	#
	#  /etc/profiles/per-user/directxman12/etc/profile.d/hm-session-vars.sh
	#
	# if you don't want to manage your shell through Home Manager.
	home.sessionVariables = {
		# already set below by programs.neovim
		# EDITOR = "vim";
	};

	#
	# programs
	#

	# git
	programs.git = {
		enable = true;
		userEmail = "directxman12+gh@gmail.com";
		userName = "Solly Ross";
		extraConfig = { init.defaultBranch = "main"; };
	};

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;
}
