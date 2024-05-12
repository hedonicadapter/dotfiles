vim.o.showmode = false
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.g.mapleader = " "
vim.g.maplocalleader = " "
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
vim.o.scrolloff = 999
vim.opt.cmdheight = 1
vim.g.have_nerd_font = true
vim.opt.guifont = "ProggyClean Nerd Font"
vim.o.guicursor = "n-v-c-sm-i-ci-ve:block,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
vim.o.cmdheight = 0

if vim.g.neovide then
	vim.opt.guifont = "Iosevka Term"
	vim.opt.linespace = 15

	vim.g.neovide_padding_top = 4
	vim.g.neovide_padding_bottom = 4
	vim.g.neovide_padding_right = 4
	vim.g.neovide_padding_left = 4

	vim.g.neovide_scroll_animation_length = 0.15

	vim.g.neovide_theme = "auto"

	vim.g.neovide_refresh_rate = 144
	vim.g.neovide_refresh_rate_idle = 5

	vim.g.neovide_cursor_smooth_blink = true
	vim.g.neovide_fullscreen = false
	vim.g.neovide_remember_window_size = false
end

vim.api.nvim_set_hl(0, "DropBarIconKindFunction", {
	bg = "#000000",
})

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

-- Hide message after writing a file
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
		local win_h = vim.api.nvim_win_get_height(0)
		local off = math.min(vim.o.scrolloff, math.floor(win_h / 2))
		local dist = vim.fn.line("$") - vim.fn.line(".")
		local rem = vim.fn.line("w$") - vim.fn.line("w0") + 1
		if dist < off and win_h - rem + dist < off then
			local view = vim.fn.winsaveview()
			view.topline = view.topline + off - (win_h - rem + dist)
			vim.fn.winrestview(view)
		end
	end,
})

vim.api.nvim_exec(
	[[
  autocmd BufEnter * hi TreesitterContextBottom gui=underline 
]],
	false
)

vim.api.nvim_exec(
	[[
  autocmd BufEnter * setlocal cursorline 
]],
	false
)
vim.api.nvim_exec(
	[[
  autocmd BufEnter * set relativenumber
]],
	false
)

vim.api.nvim_exec(
	[[
  autocmd BufEnter * hi DropBarIconKindFunction guibg=#000000
]],
	false
)

vim.api.nvim_exec(
	[[
  autocmd BufEnter * hi WinBar guibg=NONE
]],
	false
)

-- Remap keys for apply code actions at the cursor position.
-- vim.keymap.set("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", opts)
-- Remap keys for apply source code actions for current file.
-- vim.keymap.set("n", "<leader>fca", "<Plug>(coc-codeaction-source)", opts)
-- Apply the most preferred quickfix action on the current line.
-- vim.keymap.set("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

-- vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
