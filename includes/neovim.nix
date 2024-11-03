{ config, pkgs, ... }:

let
	obsidian-nvim = pkgs.vimUtils.buildVimPlugin {
		pname = "obsidian.nvim";
		version = "1.14.3-alpha.1";

		src = pkgs.fetchFromGitHub {
			owner = "epwalsh";
			repo = "obsidian.nvim";
			rev = "430bee736fc48170362f38ba1217596d241abdaa";
			hash = "sha256-qV2gfNU7Du0JsM3CwaoW/w+JZ5N4JCGfEGr/tC3TVwM=";
		};
	};
in
{
	programs.neovim = {
		enable = true;
		# this is gonna be latest anyway, no need to override package

		# set {vi,vim} to nvim
		viAlias = true;
		vimAlias = true;
		vimdiffAlias = true;
		defaultEditor = true;

		extraPackages = with pkgs; [
			# for compiling treesitter stuff
			# gcc
		];

		extraLuaConfig = builtins.readFile ../snippets/nvim.lua;

		plugins = with pkgs.vimPlugins; [
			# system helpers
			{
				plugin = nvim-treesitter.withAllGrammars; # highlighting and semantic-aware motions
				type = "lua";
				config = ''
					require('nvim-treesitter.configs').setup {
						highlight = { enable = true, },

						-- select by param, and such
						textobjects = {
							select = {
								enable = true,
								keymaps = {
									["ia"] = "@parameter.inner",
									["aa"] = "@parameter.outer",
								},
							},

							-- move between params and such
							move = {
								enable = true,
								set_jumps = true,
								goto_next_start = {
									["]m"] = "@function.outer",
									["]a"] = "@parameter.inner",
								},
								goto_next_end = {
									["]M"] = "@function.outer",
									["]A"] = "@parameter.outer",
								},
								goto_previous_start = {
									["[m"] = "@function.outer",
									["[a"] = "@parameter.inner",
								},
								goto_previous_end = {
									["[M"] = "@function.outer",
									["[A"] = "@parameter.outer",
								},
							},
						},

						refactor = {
							smart_rename = {
								enable = true,
								keymaps = {
									-- normally `grr` would be virtual-replace [single] r,
									-- but that's kinda not super useful, so use it for
									-- "rname in current scope" instead
									smart_rename = "grr",
								},
							},
						},
					}
				'';
			}
			nvim-treesitter-textobjects # change-in-arg and such
			nvim-treesitter-refactor # change-in-arg and such
			playground # nice for debugging weird editor issues
			# lsp configs & helpers
			{
				plugin = nvim-lspconfig;
				type = "lua";
				config = ''
					vim.api.nvim_create_autocmd({'LspAttach'}, {
						group = vim.api.nvim_create_augroup('UserLspConfig', {}),
						callback = function(ev)
							-- show the spinner thing
							require'fidget'.setup{}

							-- keymappings
							-- enable omnifunc completion
							vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

							local opts = { buffer = ev.buf }
							-- info & nav
							vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
							vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
							vim.keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition, opts) -- leader to avoid overlap with gt (tabnext)
							vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
							vim.keymap.set('n', '<leader>=', vim.lsp.buf.format, opts)
							vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
							vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
							vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

							-- diagnostics
							vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
							vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
							vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
							vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

							-- telescope
							vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
							vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, opts)
							vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, opts)

							-- always show the sign column, so we don't flicker
							vim.opt.signcolumn = 'yes'

							-- show inlay hints, if available
							local client = vim.lsp.get_client_by_id(ev.data.client_id)
							if client.server_capabilities.inlayHintProvider then
								vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
							end
						end
					})
				'';
			}
			# show lsp status
			{
				plugin = fidget-nvim;
				type = "lua";
				config = ''
					-- configured above in the lsp-config autocmd
				'';
			}

			# visual
			# TODO: switch to solarized-osaka or something with better support for inlay hints, etc
			nvim-solarized-lua # colors! with treesitter support
			# status line...
			{
				plugin = lualine-nvim;
				type = "lua";
				config = ''
					require('lualine').setup {
						options = { theme = 'solarized' },
						sections = {
							-- show relative path instead of just filename
							lualine_c = {{'filename', path = 1}},
						},
					}
				'';
			}
			nvim-web-devicons # ... and the fancy icons it requires..
			# ... and the tabline that also uses them
			# barbar is nice, but causes flickers in light mode
			# consider switching to cokeline, lualine builtin, or heirline
			# if it becomes too annoying
			barbar-nvim

			# external integrations
			vim-fugitive # git!
			{ plugin = neomake; optional = true; } # tbh i don't use this much but it's nice to have around
			# extra helpers for the rust lsp integration
			# rust-tools-nvim is deprecated, use rustaceanvim
			# {
			# 	plugin = rust-tools-nvim;
			# 	type = "lua";
			# 	config = ''
			# 		require('rust-tools').setup {
			# 			server = { -- would be passed to LSP config
			# 				settings = {
			# 					['rust-analyzer'] = {
			# 						assist = {
			# 							importGranularity = 'module',
			# 							importPrefix = 'by_self',
			# 						},
			# 						cargo = { loadOutDirsFromCheck = true, },
			# 						procMacro = { enable = true, },
			# 					},
			# 				},
			# 			},
			# 		}
			# 	'';
			# }
			{
				plugin = rustaceanvim;
				type = "lua";
				config = ''
					vim.g.rustaceanvim = {
						default_settings = {
							['rust-analyzer'] = {
								assist = {
									importGranularity = 'module',
									importPrefix = 'by_self',
								},
								cargo = { loadOutDirsFromCheck = true, },
								procMacro = { enable = true, },
							},
						},
					}
				'';
			}
			{
				plugin = obsidian-nvim;
				type = "lua";
				config = ''
					require('obsidian').setup{
						dir = "~/Documents/obsidian/notes",
						disable_frontmatter = true,
					}
				'';
			}

			# shortcuts
			vim-abolish # case-preserving operations
			vim-commentary # comment/uncomment
			nvim-treesitter-refactor # treesitter assists for stuff that lsp normally does

			# support
			{
				plugin = telescope-nvim;
				type = "lua";
				config = ''
					require('telescope').setup {
						pickers = {
							defaults = { theme = 'ivy', },

							lsp_references = { initial_mode = 'normal' },
						},
					}

					vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)
					vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep)
					vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers)
					vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags)
					vim.keymap.set('n', '<leader>ft', require('telescope.builtin').treesitter)
				'';
			}
		];
	};
}
