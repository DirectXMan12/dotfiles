{ config, pkgs, alacritty-apply, ... }:

{
	# noctalia shell (bar, launcher, etc -- replaces waybar)
	programs.noctalia = {
		enable = true;
		settings = {
			theme = {
				mode = "auto";
				source = "community";
				# community_palette = "Solarized Osaka";
				community_palette = "Solarized";
			};
			idle.behavior = {
				# lock and screen-off automatically, but don't suspend
				# automatically
				lock.enabled = true;
				screen-off.enabled = true;
				lock-and-suspend = {
					enabled = true;
					timeout = 0;
				};
			};
			notification.enable_daemon = true;
			shell = {
				greeter_sync.auto_sync = true;
				launch_apps_custom_command = "swaymsg exec -- $CMD";
				animation.enabled = false;

				launcher.dmenu.entry = {
					"nix-run" = {
						label = "nix run";
						prefix = "nix-run";
						glyph = "hexagon-letter-n";
						global = false;
						exec = "swaymsg exec -- nix run nixpkgs#{query}";
						freeform = true;
					};
					"nix-shell" = {
						label = "nix shell";
						prefix = "nix-shell";
						glyph = "hexagon-letter-n";
						global = false;
						exec = "swaymsg exec -- '$term' -e nix shell nixpkgs#{query} -c nu";
						freeform = true;
					};
				};
			};
			calendar = {
				enabled = true;
				account.personal_google = {
					name = "Solly (Google)";
					type = "google";
				};
			};
			hooks = {
				theme_mode_changed = let
					# TODO: make alap's bin match up with what nix expects
					alap = "${alacritty-apply.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/alap";
					hook-script = pkgs.writers.writeNuBin "theme-mode-changed.nu" ''
						let alacritty_themes: record<light: path, dark: path> = {
							light: "${./alacritty/solarized-light.toml}",
							dark: "${./alacritty/solarized-dark-custom.toml}"
						}
						$env.ALACRITTY_SOCKET = ($env.ALACRITTY_SOCKET? | default {
							ls $"($env.XDG_RUNTIME_DIR)/Alacritty-($env.WAYLAND_DISPLAY | str replace "/" "-")-*" | where type == "socket" | get 0.name
						})
						if $env.NOCTALIA_THEME_MODE == "light" {
							${alap} -w=all $alacritty_themes.light
						} else {
							${alap} -w=all $alacritty_themes.dark
						}
					'';
				in
					pkgs.lib.getExe hook-script;
			};
			bar.default = {
				thickness = 21;
				position = "bottom";
				margin_ends = 0;
				radius = 0;

				start = [ "launcher" "wallpaper" "workspaces" ];
				center = [ "active_window" ];
				end = [ "notifications" "clipboard" "volume" "network" "bluetooth" "brightness" "battery" "control-center" "clock" "tray" "session" ];
			};
			widget.workspaces = {
				type = "workspaces";
				enabled = true;
				max_label_chars = 10;
			};
			weather = {
				enabled = true;
				unit = "metric";
				effects = true;
				refresh_minutes = 60;
			};
			location = {
				auto_locate = true;
			};
			lockscreen_widgets = {
				enabled = true;

				widget.clock_main = {
					type = "clock";
					cx = 960.0;
					cy = 540.0;
					settings = {
						format = "{:%H:%M}";
					};
				};
			};
			control_center.hidden_tabs = [ "media" ];
		};
	};

	services.gnome-keyring.enable = true;
}
