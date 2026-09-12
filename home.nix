{ config, pkgs, browser-previews, ... }:

let
	# don't actually install this
	term-at-opener = pkgs.writeScriptBin "term-at.sh" (builtins.readFile ./scripts/term-at.sh);
	github-opener = pkgs.writeScriptBin "open-github.nu" (builtins.readFile ./scripts/open-github.nu);
	move-ws-to-output = pkgs.writeScriptBin "move-ws-to-output" (builtins.readFile ./scripts/move-ws-to-output.nu);
	rfc-opener = pkgs.writeScriptBin "open-rfc.nu" (builtins.readFile ./scripts/open-rfc.nu);
	askpass = pkgs.writers.writeNuBin "askpass.nu" ("$env.PATH ++= ['${pkgs.tofi}/bin/']\n" + (builtins.readFile ./scripts/askpass.nu));
	launcher = pkgs.writers.writeNuBin "launcher.nu" (builtins.readFile ./scripts/launcher.nu);

in

{
	# load separate files
	imports = [
		./includes/neovim.nix
		./includes/jj.nix
		./includes/nushell
		./includes/alacritty
		./includes/noctalia.nix
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
		tree
		unzip
		dig
		bat
		fd
		ripgrep
		wget
		curl
		htop

		# till the latest in nixos
		obsidian

		# google-chrome-dev # moving to system level to match pipewire?

		# # You can also create simple shell scripts directly inside your
		# # configuration. For example, this adds a command 'my-hello' to your
		# # environment:
		# (pkgs.writeShellScriptBin "my-hello" ''
		#		echo "Hello, ${config.home.username}!"
		# '')

		move-ws-to-output

		# fonts for all this stuff
		font-awesome
		nerd-fonts.dejavu-sans-mono
		noto-fonts
		noto-fonts-color-emoji
		noto-fonts-cjk-serif
		noto-fonts-cjk-sans
		dejavu_fonts
	];

	# Home Manager is pretty good at managing dotfiles. The primary way to manage
	# plain files is through 'home.file'.
	home.file = {
		# # You can also set the file content immediately.
		# ".gradle/gradle.properties".text = ''
		#		org.gradle.console=verbose
		#		org.gradle.daemon.idletimeout=3600000
		# '';
	};

	# (and for .config dirs)
	xdg.configFile = {
		"sway/config".source = xdg-configs/sway/config;
		"sway/config.d.after/launch-noctalia".text = ''
			exec "TERMINAL=${pkgs.lib.getExe launcher} noctalia"
		'';
		"tofi/config".source = xdg-configs/tofi/config;
		"kanshi/config".source = xdg-configs/kanshi/config;

		"waybar/config".source = xdg-configs/waybar/config;
		"waybar/style.css".source = xdg-configs/waybar/style.css;

		"swaylock/config".source = xdg-configs/swaylock/config;
		"fontconfig/conf.d/52-default-fonts.conf".source = xdg-configs/fontconfig/52-default-fonts.conf;
	};
	xdg.mimeApps = {
		enable = true;
		defaultApplications = {
			"x-scheme-handler/term-at" = ["term-at-scheme-handler.desktop"];
			"x-scheme-handler/github" = ["github-scheme-handler.desktop"];
			"x-scheme-handler/rfc" = ["rfc-scheme-handler.desktop"];

			# manually manage chrome's defaults
			"text/html" = ["google-chrome-unstable.desktop"];
			"x-scheme-handler/http" = ["google-chrome-unstable.desktop"];
			"x-scheme-handler/https" = ["google-chrome-unstable.desktop"];
			"x-scheme-handler/about" = ["google-chrome-unstable.desktop"];
			"x-scheme-handler/unknown" = ["google-chrome-unstable.desktop"];
		};
	};
	xdg.desktopEntries = {
		term-at-scheme-handler = {
			name = "term-at Scheme Handler";
			exec = "${term-at-opener}/bin/term-at.sh %u";
			type = "Application";
			terminal = false;
			startupNotify = false;
			mimeType = [ "x-scheme-handler/term-at" ];
			noDisplay = true;
		};
		github-scheme-handler = {
			name = "github Scheme Handler";
			exec = "${github-opener}/bin/open-github.nu %u";
			type = "Application";
			terminal = false;
			startupNotify = false;
			mimeType = [ "x-scheme-handler/github" ];
			noDisplay = true;
		};
		rfc-scheme-handler = {
			name = "rfc Scheme Handler";
			exec = "${rfc-opener}/bin/open-rfc.nu %u";
			type = "Application";
			terminal = false;
			startupNotify = false;
			mimeType = [ "x-scheme-handler/rfc" ];
			noDisplay = true;
		};
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

	fonts.fontconfig.enable = true;

	#
	# programs
	#

	# git
	programs.git = {
		enable = true;
		userEmail = "directxman12+gh@gmail.com";
		userName = "Solly Ross";
		extraConfig = {
			init.defaultBranch = "main";
			safe.directory = ["/etc/nixos"];
		};
	};

	services.ssh-agent.enable = true;
	systemd.user.services."ssh-agent".Service.Environment = [
		"SSH_ASKPASS=${askpass}/bin/askpass.nu"
	];

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;
}
