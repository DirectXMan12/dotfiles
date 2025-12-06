{ config, pkgs, ... }:

let
	email = "git@metamagical.dev";
in
{
	programs.jujutsu = {
		enable = true;
		settings = {
			"merge-tools" = {
				# diff editor
				"nvim-difftool" = {
					program = "vim";
					edit-args = ["-c" "packadd nvim.difftool" "-c" "DiffTool $left $right"];
				};

				# for diff viewing
				difft = {
					# turn on light background to get difftastic to work well with
					# solarized
					diff-args = ["--color=always" "--syntax-highlight=on" "--background=light" "$left" "$right"];
					program = "${pkgs.difftastic}/bin/difft";
				};
			};
			ui = {
				editor = "vim"; # neovim
				diff-editor = "nvim-difftool";
				merge-editor = "vimdiff";
			};
			user = {
				name = "Solly Ross";
				email = email;
			};

			templates = {
				git_push_bookmark = ''"sollyross/" ++ change_id.short()"'';
			};

			revset-aliases = {
				"immutable_heads()" = "builtin_immutable_heads() | next@origin | remote_bookmarks(~glob:'sollyross/*')";
				"unsafe_stragglers()" = "::heads(all()) & ~(::remote_bookmarks(remote=origin) | ::bookmarks() | ::git_refs())";
			};
		};
	};
}
