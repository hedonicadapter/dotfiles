vim.o.showmode = false
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.backspace = "indent,eol,start"
vim.opt.clipboard:append("unnamedplus")
vim.g.have_nerd_font = true
vim.opt.guifont = "JetBrainsMono Nerd Font"
vim.o.guicursor = "n-v-c-sm-i-ci-ve:block,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
vim.o.cmdheight = 0

if vim.g.neovide then
	vim.opt.linespace = 15

	vim.g.neovide_padding_top = 10
	vim.g.neovide_padding_bottom = 0
	vim.g.neovide_padding_right = 20
	vim.g.neovide_padding_left = 20

	vim.g.neovide_theme = "auto"

	vim.g.neovide_refresh_rate = 144
	vim.g.neovide_refresh_rate_idle = 5
	vim.g.neovide_fullscreen = false
	vim.g.neovide_remember_window_size = false
	vim.g.neovide_scale_factor = 0.75

	vim.g.neovide_scroll_animation_length = 0.1
	vim.g.neovide_cursor_smooth_blink = true
	vim.g.neovide_floating_shadow = false

	-- Helper function for transparency formatting
	local alpha = function()
		return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
	end
	-- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
	vim.g.neovide_transparency = 0.8
	-- vim.g.transparency = 0.8
	vim.g.neovide_background_color = "#34302C" -- .. alpha()
	vim.g.neovide_window_blurred = true

	vim.keymap.set("n", "<C-s>", ":w<CR>") -- Save
	vim.keymap.set("v", "<C-c>", '"+y') -- Copy
	vim.keymap.set("n", "<C-v>", '"+P') -- Paste normal mode
	vim.keymap.set("v", "<C-v>", '"+P') -- Paste visual mode
	vim.keymap.set("c", "<C-v>", "<C-R>+") -- Paste command mode
	vim.keymap.set("i", "<C-v>", '<ESC>l"+Pli') -- Paste insert mode

	vim.api.nvim_set_keymap("", "<C-v>", "+p<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("!", "<C-v>", "<C-R>+", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("t", "<C-v>", "<C-R>+", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("v", "<C-v>", "<C-R>+", { noremap = true, silent = true })
end

vim.cmd([[highlight Normal guibg=none]])

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc" -- Buffer local mappings.-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = {
			buffer = ev.buf,
		}
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({
				async = true,
			})
		end, opts)
	end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
	group = vim.api.nvim_create_augroup("cmdheight_1_on_cmdlineenter", {
		clear = true,
	}),
	desc = "Don't hide the status line when typing a command",
	command = ":set cmdheight=1",
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	group = vim.api.nvim_create_augroup("cmdheight_0_on_cmdlineleave", {
		clear = true,
	}),
	desc = "Hide cmdline when not typing a command",
	command = ":set cmdheight=0",
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("hide_message_after_write", {
		clear = true,
	}),
	desc = "Get rid of message after writing a file",
	pattern = { "*" },
	command = "redrawstatus",
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
	group = grp,
	callback = function()
		local bufname = vim.fn.bufname()

		if bufname == "Starter" then
			vim.o.scrolloff = 0
		else
			-- local win_h = vim.api.nvim_win_get_height(0)
			-- local off = math.min(vim.o.scrolloff, math.floor(win_h / 2))
			-- local dist = vim.fn.line("$") - vim.fn.line(".")
			-- local rem = vim.fn.line("w$") - vim.fn.line("w0") + 1
			-- if dist < off and win_h - rem + dist < off then
			-- 	local view = vim.fn.winsaveview()
			-- 	view.topline = view.topline + off - (win_h - rem + dist)
			-- 	vim.fn.winrestview(view)
			-- end
			vim.o.scrolloff = 999
		end
	end,
})

vim.api.nvim_exec(
	[[
  autocmd BufEnter * hi TreesitterContextBottom guisp=NONE
  autocmd BufEnter * hi TreesitterContext guibg=NONE gui=italic
  autocmd BufEnter * hi WinBar guibg=NONE
  autocmd BufEnter * hi LineNr guibg=NONE
  autocmd BufEnter * hi SignColumn guibg=NONE
  autocmd BufEnter * hi DropBarIconKindFunction guibg=NONE
]],
	false
)

vim.api.nvim_exec(
	[[
  autocmd BufEnter * set relativenumber
]],
	false
)
