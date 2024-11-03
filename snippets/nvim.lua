---- system config ----
-- disable python providers, as they take forever to load
-- TODO(directxman12): see if there's a way around this
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0

-- some convinient aliases for lua
local opt = vim.opt
local cmd = vim.cmd
local api = vim.api

---- Visual Settings ----
opt.termguicolors = true      -- first, for solarized we need 24-bit color...
cmd.colorscheme 'solarized'   -- ... then actually enable it

-- make lsp & TS errors more tolerable
api.nvim_set_hl(0, 'TSError', { link = 'normal' })
api.nvim_set_hl(0, 'LspDiagnosticsDefaultError', { fg='#73545a' })
api.nvim_set_hl(0, 'DiagnosticError', { fg='#73545a' }) -- blend between bg & term color 210
api.nvim_set_hl(0, 'DiagnosticHint', { fg='#6d6316' }) -- blend between bg & solarized yellow
api.nvim_set_hl(0, 'DiagnosticWarn', { fg='#6d6316' })

-- make lsp inlay hints look nice
-- TODO: just use solarized-osaka or something to get better highlighting
api.nvim_set_hl(0, 'LspInlayHint', { link = 'Comment' })

---- General Settings ---
-- indent stuff
opt.ts = 2
opt.sw = 2
opt.autoindent = true
opt.expandtab = false -- tabs ftw

-- filetype stuff
api.nvim_create_autocmd({'FileType'}, { pattern = 'lua', command = 'setlocal noet' })
api.nvim_create_autocmd({'FileType'}, { pattern = 'go', command = 'setlocal noet' })

-- allow switching modified buffers
opt.hidden = true

-- set terminal title
-- [VIM] {filename} {modified flag} ({cwd, shortened with tilde}) {arguments}
opt.title = true
opt.titlestring = '[VIM] %t%( %M%)%( (%{expand("%:~:h")})%)%a'

---- Keymappings ----
-- set leader to something usefule
vim.g.mapleader = " " -- <space>

-- ln is normally lnoremap, which has like zero need for an abbreviation;
-- lne is a much better use
cmd.cabbrev('ln', 'lne')
