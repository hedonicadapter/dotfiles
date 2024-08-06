vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap
local nvim_set_keymap = vim.api.nvim_set_keymap

local function set_keymap_for_all_modes(key, cmd)
	local modes = { "n", "v", "x", "s", "o", "l" }
	for _, mode in ipairs(modes) do
		nvim_set_keymap(mode, key, cmd, {
			noremap = true,
			silent = true,
		})
	end
end

nvim_set_keymap("n", "<leader>sf", "<cmd>w<CR>", {
	desc = "save",
	noremap = true,
	silent = true,
})

set_keymap_for_all_modes("<leader>qq", "<cmd>qa<CR>")

nvim_set_keymap("n", "<leader>u", "<cmd>Telescope undo<CR>", {
	noremap = true,
	silent = true,
})

nvim_set_keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", {
	noremap = true,
	silent = true,
})

nvim_set_keymap("n", "<leader>sv", "<C-w>v", {
	noremap = true,
	desc = "split vertical",
})
nvim_set_keymap("n", "<leader>sh", "<C-w>s", {
	noremap = true,
	desc = "split horizontal",
})
nvim_set_keymap("n", "<leader>sx", ":close<CR>", {
	noremap = true,
	desc = "close window",
})

nvim_set_keymap("n", "<leader>bd", ":bd<CR><CR>", {
	noremap = true,
	desc = "close buffer",
})

nvim_set_keymap("v", "y", "ygv<esc>", {
	noremap = true,
})

nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", {
	noremap = true,
})

nvim_set_keymap("n", "<Tab>", ":bnext<CR>", {
	noremap = true,
	silent = true,
})
nvim_set_keymap("n", "<S-Tab>", ":bprev<CR>", {
	noremap = true,
	silent = true,
})

nvim_set_keymap("n", "<C-j>", ":m .+1<CR>==", { -- move line down
	noremap = true,
	silent = true,
})
nvim_set_keymap("n", "<C-k>", ":m .-2<CR>==", { -- move line up
	noremap = true,
	silent = true,
})
nvim_set_keymap("i", "<C-j>", "<Esc>:m .+1<CR>==gi", {
	noremap = true,
	silent = true,
})
nvim_set_keymap("i", "<C-k>", "<Esc>:m .-2<CR>==gi", {
	noremap = true,
	silent = true,
})
nvim_set_keymap("v", "<C-j>", ":m '>+1<CR>gv", {
	noremap = true,
	silent = true,
})
nvim_set_keymap("v", "<C-k>", ":m '<-2<CR>gv", {
	noremap = true,
	silent = true,
})

nvim_set_keymap("v", "y", "ygv", {
	noremap = true,
})
nvim_set_keymap("v", ">", ">gv", {
	noremap = true,
})
nvim_set_keymap("v", "<", "<gv", {
	noremap = true,
})

-- paste and then reselect pasted text
keymap.set({ "n", "x" }, "p", "p`[v`]o", { noremap = true, silent = true })
-- yank and then reselect yanked text
keymap.set({ "n", "x" }, "y", "y`[v`]", { noremap = true, silent = true })

keymap.set("x", "<leader>p", '"_dP') -- Paste without copying
keymap.set("n", "<leader>ra", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
keymap.set("n", "<space>e", vim.diagnostic.open_float)
keymap.set("n", "[d", vim.diagnostic.goto_prev)
keymap.set("n", "]d", vim.diagnostic.goto_next)
keymap.set("n", "<space>q", vim.diagnostic.setloclist)

keymap.set("n", "<leader>n", "<Cmd>call search('[([{<\\|\"\\|'']')<CR>", {
	desc = "Jump to next brace, quote, or paren",
})
keymap.set("n", "<leader>p", "<Cmd>call search('[([{<\\|\"\\|'']', 'b') <CR>", {
	desc = "Jump to previous brace, quote, or paren",
})

-- Telescope
vim.api.nvim_exec(
	[[
            function! GetVisualSelection()
                let [lnum1, col1] = getpos("'<")[1:2]
                let [lnum2, col2] = getpos("'>")[1:2]
                let lines = getline(lnum1, lnum2)
                if len(lines) == 0
                    return ''
                endif
                let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
                let lines[0] = lines[0][col1 - 1:]
                return join(lines, "\n")
            endfunction
        ]],
	false
)

nvim_set_keymap("n", "<leader>ss", "<cmd>Telescope session-lens<cr>", { noremap = true, silent = true })

nvim_set_keymap(
	"n",
	"<leader>fw",
	[[:lua require('telescope.builtin').live_grep({ default_text = vim.fn.expand('<cword>') })<CR>]],
	{
		noremap = true,
		silent = true,
		desc = "find word under cursor",
	}
)

nvim_set_keymap(
	"v",
	"<leader>fs",
	[[:lua require('telescope.builtin').live_grep({ default_text = vim.fn.GetVisualSelection() })<CR>]],
	{
		noremap = true,
		silent = true,
		desc = "find selection",
	}
)
set_keymap_for_all_modes("<leader>ff", ":Telescope find_files<CR>")
set_keymap_for_all_modes("<leader>fr", ":Telescope resume<CR>")
set_keymap_for_all_modes("<leader>lg", ":Telescope live_grep<CR>")

nvim_set_keymap(
	"n",
	"<leader>o",
	"<CMD>SymbolsOutline<CR>",
	{ desc = "Symbols outline", noremap = true, silent = true }
)

nvim_set_keymap(
	"n",
	"<leader>0",
	"<CMD>lua require('CopilotChat').toggle()<CR>",
	{ desc = "Open Copilot Chat", noremap = true, silent = true }
)

-- SnipRun
nvim_set_keymap("n", "<leader>sr", "<CMD>SnipRun<CR>", { desc = "Run SnipRun", noremap = true, silent = true })
keymap.set(
	{ "v", "x" },
	"<leader>sr",
	":'<,'>SnipRun<CR>",
	{ desc = "Run SnipRun in visual mode", noremap = true, silent = true }
)

-- flash.nvim
keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { noremap = true })
keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { noremap = true })

nvim_set_keymap(
	"v",
	"<leader>ls",
	":lua require('plugins.toggle-print').toggle_print()<CR>",
	{ noremap = true, silent = true }
)

keymap.set("n", "<leader>dn", "<cmd>lua vim.diagnostic.goto_next()<CR>")
keymap.set("n", "<leader>dp", "<cmd>lua vim.diagnostic.goto_prev()<CR>")

-- credit: u/xmsxms
keymap.set("n", "<leader>bc", function()
	local curbufnr = vim.api.nvim_get_current_buf()
	local buflist = vim.api.nvim_list_bufs()
	for _, bufnr in ipairs(buflist) do
		if vim.bo[bufnr].buflisted and bufnr ~= curbufnr and (vim.fn.getbufvar(bufnr, "bufpersist") ~= 1) then
			vim.cmd("bd " .. tostring(bufnr))
		end
	end
end, { silent = true, desc = "Close unused buffers" })
