local o = vim.o
local opt = vim.opt
local g = vim.g
local keymap = vim.keymap
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local exec = vim.api.nvim_exec

o.showmode = false
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
opt.autoindent = true
opt.expandtab = true
opt.wrap = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.ttimeoutlen = 10
opt.ignorecase = true
opt.smartcase = true
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")
g.have_nerd_font = true
opt.guifont = "CartographCF Nerd Font"
o.guicursor = "n-v-c-sm-i-ci-ve:block,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
o.cmdheight = 0
o.sidescroll = 1
o.sidescrolloff = 20
opt.undofile = true
opt.fillchars:append(",eob: ")

if g.neovide then
	opt.linespace = 10

	g.neovide_padding_top = 10
	g.neovide_padding_bottom = 0
	g.neovide_padding_right = 20
	g.neovide_padding_left = 20

	g.neovide_theme = "auto"

	g.neovide_refresh_rate = 144
	g.neovide_refresh_rate_idle = 5
	g.neovide_fullscreen = false
	g.neovide_remember_window_size = false
	g.neovide_scale_factor = 0.8
	-- g.neovide_scale_factor = 1.25

	g.neovide_scroll_animation_length = 0.1
	g.neovide_cursor_smooth_blink = true
	g.neovide_floating_shadow = false

	-- Helper function for transparency formatting
	-- local alpha = function()
	-- 	return string.format("%x", math.floor(255 * g.transparency or 0.8))
	-- end
	-- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
	g.neovide_transparency = 0.8
	-- g.transparency = 0.8
	-- g.neovide_background_color = "#34302C" -- .. alpha()
	g.neovide_window_blurred = true

	keymap.set("n", "<C-s>", ":w<CR>") -- Save
	keymap.set("v", "<C-c>", '"+y') -- Copy
	keymap.set("n", "<C-v>", '"+P') -- Paste normal mode
	keymap.set("v", "<C-v>", '"+P') -- Paste visual mode
	keymap.set("c", "<C-v>", "<C-R>+") -- Paste command mode
	keymap.set("i", "<C-v>", '<ESC>l"+Pli') -- Paste insert mode

	keymap.set("", "<C-v>", "+p<CR>", { noremap = true, silent = true })
	keymap.set("!", "<C-v>", "<C-R>+", { noremap = true, silent = true })
	keymap.set("t", "<C-v>", "<C-R>+", { noremap = true, silent = true })
	keymap.set("v", "<C-v>", "<C-R>+", { noremap = true, silent = true })
end

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
autocmd("LspAttach", {
	group = augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc" -- Buffer local mappings.-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = {
			buffer = ev.buf,
		}
		local lsp_buf = vim.lsp.buf

		keymap.set("n", "gD", lsp_buf.declaration, opts)
		keymap.set("n", "gd", lsp_buf.definition, opts)
		keymap.set("n", "K", lsp_buf.hover, opts)
		keymap.set("n", "gi", lsp_buf.implementation, opts)
		keymap.set("n", "<C-k>", lsp_buf.signature_help, opts)
		keymap.set("n", "<space>wa", lsp_buf.add_workspace_folder, opts)
		keymap.set("n", "<space>wr", lsp_buf.remove_workspace_folder, opts)
		keymap.set("n", "<space>wl", function()
			print(vim.inspect(lsp_buf.list_workspace_folders()))
		end, opts)
		keymap.set("n", "<space>D", lsp_buf.type_definition, opts)
		keymap.set("n", "<space>rn", lsp_buf.rename, opts)
		keymap.set({ "n", "v" }, "<space>ca", lsp_buf.code_action, opts)
		keymap.set("n", "gr", lsp_buf.references, opts)
		keymap.set("n", "<space>f", function()
			lsp_buf.format({
				async = true,
			})
		end, opts)
	end,
})

-- autocmd("CmdlineEnter", {
-- 	group = augroup("cmdheight_1_on_cmdlineenter", {
-- 		clear = true,
-- 	}),
-- 	desc = "Don't hide the status line when typing a command",
-- 	command = ":set cmdheight=1",
-- })

-- autocmd("CmdlineLeave", {
-- 	group = augroup("cmdheight_0_on_cmdlineleave", {
-- 		clear = true,
-- 	}),
-- 	desc = "Hide cmdline when not typing a command",
-- 	command = ":set cmdheight=0",
-- })

autocmd("BufWritePost", {
	group = augroup("hide_message_after_write", {
		clear = true,
	}),
	desc = "Get rid of message after writing a file",
	pattern = { "*" },
	command = "redrawstatus",
})

autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
	callback = function()
		local bufname = vim.fn.bufname()

		if bufname == "Starter" then
			o.scrolloff = 0
		else
			-- local win_h = vim.api.nvim_win_get_height(0)
			-- local off = math.min(o.scrolloff, math.floor(win_h / 2))
			-- local dist = vim.fn.line("$") - vim.fn.line(".")
			-- local rem = vim.fn.line("w$") - vim.fn.line("w0") + 1
			-- if dist < off and win_h - rem + dist < off then
			-- 	local view = vim.fn.winsaveview()
			-- 	view.topline = view.topline + off - (win_h - rem + dist)
			-- 	vim.fn.winrestview(view)
			-- end
			o.scrolloff = 999
		end
	end,
})

exec(
	[[
		autocmd BufEnter * hi TreesitterContextBottom guisp=NONE
		autocmd BufEnter * hi TreesitterContext guibg=NONE gui=italic
		autocmd BufEnter * hi WinBar guibg=NONE
		autocmd BufEnter * hi LineNr guibg=NONE
		autocmd BufEnter * hi SignColumn guibg=NONE
		autocmd BufEnter * hi DropBarIconKindFunction guibg=NONE
		autocmd BufEnter * hi TabLineFill guibg=NONE
		autocmd BufEnter * hi DiagnosticSignError guibg=NONE
		autocmd BufEnter * hi DiagnosticSignWarn guibg=NONE
		autocmd BufEnter * hi DiagnosticSignInfo guibg=NONE
		autocmd BufEnter * hi DiagnosticSignHint guibg=NONE
		autocmd BufEnter * hi DiagnosticSignOk guibg=NONE
		autocmd BufEnter * hi Folded guibg=NONE
		autocmd BufEnter * hi Twilight guibg=NONE
		autocmd BufEnter * hi GitSignsAdd guibg=NONE
		autocmd BufEnter * hi GitSignsChange guibg=NONE
		autocmd BufEnter * hi GitSignsDelete guibg=NONE
		autocmd BufEnter * hi VertSplit guibg=NONE ctermbg=NONE
	]],
	false
)

exec(
	[[
		autocmd BufEnter * set relativenumber
		autocmd BufEnter * set number
		autocmd BufEnter * set cursorline
		autocmd BufEnter * if expand('<afile>:t') != 'copilot-chat' | set nowrap | setlocal signcolumn=no | endif
	]],
	false
)

exec(
	[[
		autocmd BufEnter *.cshtml set filetype=html.cshtml.razor
		autocmd BufEnter *.razor set filetype=html.cshtml.razor
	]],
	false
)
