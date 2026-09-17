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
				"nvim" = {
					program = "nvim";
					edit-args = ["-c" "packadd nvim.difftool" "-c" "DiffTool $left $right"];
					merge-args = ["-f" "-d" "$output" "-M" "$left" "$base" "$right"
												"-c" "wincmd J" "-c" "set modifiable" "-c" "set write"
												"-c" "/<<<<<</+2"];
					merge-tool-edits-conflict-markers = true;
					diff-args = [];
				};

				# for diff viewing
				difft = {
					# turn on light background to get difftastic to work well with
					# solarized
					diff-args = ["--color=always" "--syntax-highlight=off" "--background=light" "$left" "$right"];
					program = "${pkgs.difftastic}/bin/difft";
				};
			};
			ui = {
				editor = "vim"; # neovim
				diff-editor = "nvim";
				merge-editor = "nvim";
			};
			user = {
				name = "Solly Ross";
				email = email;
			};

			templates = {
				git_push_bookmark = ''"sollyross/" ++ change_id.short()"'';
			};

			revsets = {
				"bookmark-advance-to" = "closest_pushable(@)";
			};

			revset-aliases = {
				"immutable_heads()" = "builtin_immutable_heads() | remote_bookmarks(glob:'ci/*') | remote_bookmarks(~glob:'*/*')";
				"unsafe_stragglers()" = "::heads(all()) & ~(::remote_bookmarks(remote=origin) | ::bookmarks() | ::git_refs())";

				"closest_pushable(to)" = '' heads(::to & mutable() & ~description(exact:"") & ~subject(glob:"\\[tmp\\]*") & (~empty() | merges())) '';
			};
		};
	};
}
