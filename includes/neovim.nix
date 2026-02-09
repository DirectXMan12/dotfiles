{ config, pkgs, neovim-nightly, ... }:

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

		dependencies = with pkgs.vimPlugins; [
			plenary-nvim
		];
	};

	# carries patch to fix the gui=reverse tabline issue with nvim 0.11.0
	nvim-solarized-lua-local = pkgs.vimUtils.buildVimPlugin {
		pname = "nvim-solarized-lua";
		version = "1.0-2025-05-13";
		src = pkgs.fetchFromGitHub {
			owner = "directxman12";
			repo = "nvim-solarized-lua";
			rev = "c93e4661f2b785d3910d9a3f0ea56bde3b5fbd39";
			sha256 = "sha256-0m8e3QPzpZnEAIo0K3Gr1DXlbdvmV/ZtnDw+XI3bkIM=";
		};
	};
	rustaceanvim = pkgs.vimUtils.buildVimPlugin {
		pname = "rustaceanvim";
		version = "7.0.6";
		src = pkgs.fetchFromGitHub {
			owner = "mrcjkb";
			repo = "rustaceanvim";
			rev = "6c3785d6a230bec63f70c98bf8e2842bed924245"; # 7.0.6
			sha256 = "sha256-t7xAQ9sczLyA1zODmD+nEuWuLnhrfSOoPu/4G/YTGdU=";
		};
		checkInputs = with pkgs.vimPlugins; [
			neotest
		];
	};
	# telescope-jj = pkgs.vimUtils.buildVimPlugin {
	# 	pname = "telescope-jj";
	# 	version = "1.0-2025-12-05";
	# 	src = pkgs.fetchFromGitHub {
	# 		owner = "zschreur";
	# 		repo = "telescope-jj";
	# 		rev = "9527e39f30eded7950ca127698422ec412d633c4";
	# 		sha256 = "";
	# 	};
	# };
	jj-nvim = pkgs.vimUtils.buildVimPlugin {
		pname = "jj-nvim";
		version = "v0.1.0+2025-12-05";
		src = pkgs.fetchFromGitHub {
			owner = "NicolasGB";
			repo = "jj.nvim";
			rev = "ddfd6e0b564669861b6ed03871bb649724a6a527";
			sha256 = "sha256-IU1u67fupQjVu3Yw3VmxWjBsMRPJpBTTShz+7hFFpk0=";
		};
	};
in
{
	programs.neovim = {
		enable = true;
		# this is gonna be latest anyway, no need to override package

		package = neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
					vim.api.nvim_create_autocmd('FileType', {
						group = vim.api.nvim_create_augroup('treesitter-install', { clear = true }),
						pattern = { '*' },
						callback = function() vim.treesitter.start() end,
					})
				'';
			}
			{
				plugin = nvim-treesitter-textobjects; # change-in-arg and such
				type = "lua";
				config = ''
					-- select by param, and such
					require'nvim-treesitter-textobjects'.setup {
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
					}
				'';
			}
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
			nvim-solarized-lua-local # colors! with treesitter support
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
			{
				plugin = markview-nvim;
				type = "lua";
				config = ''
					require('markview').setup {
						preview = {
							-- manually enable if we want it
							enable = false,
							-- don't flicker back and forth on insert
							enable_hybrid_mode = true,
							modes = { "i", "n", "no", "c" },
							hybrid_modes = { "i" },
						},
					}
				'';
			}
			vim-fugitive # git!
			{  # jj, hopefully like vim-fugitive
				plugin = jj-nvim;
				type = "lua";
				config = ''
					require'jj'.setup{}
				'';
			}
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
						server = {
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
					}

					-- work around github:neovim/neovim#30985 until
					-- github:neovim/neovim#30999 is merged
					for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
						local default_diagnostic_handler = vim.lsp.handlers[method]
						vim.lsp.handlers[method] = function(err, result, context, config)
							if err ~= nil and err.code == -32802 then
								return
							end
							return default_diagnostic_handler(err, result, context, config)
						end
					end
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
			# telescope-jj # jj, not currently actively configured with a key
		];
	};
}
