{ config, pkgs, ... }:

{
	programs.alacritty = {
		enable = true;
		settings = {
			general = {
				import = [ ./solarized-dark-custom.toml ];
				live_config_reload = true;
			};

			terminal.shell = "${pkgs.lib.getExe config.programs.nushell.package}";

			bell.duration = 0;

			colors.draw_bold_text_with_bright_colors = true;

			hints.enabled = [{
				command = "xdg-open";
				hyperlinks = true;
				post_processing = true;
				regex = ''(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:|github:|rfc:)[^\u0000-\u001F\u007F-<>\"\\s{-}\\^⟨⟩`]+'';
				mouse = {
					enabled = true;
					mods = "Control";
				};
			}];

			mouse.bindings = [{
				action = "PasteSelection";
				mouse = "Middle";
			}];

			window.padding = {
				x = 0;
				y = 0;
			};
		};
	};
}
