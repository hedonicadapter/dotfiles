local function set_keymap_for_all_modes(key, cmd)
	local modes = { "n", "v", "x", "s", "o", "l" }
	for _, mode in ipairs(modes) do
		vim.api.nvim_set_keymap(mode, key, cmd, {
			noremap = true,
			silent = true,
		})
	end
end

vim.api.nvim_set_keymap("n", "<leader>u", "<cmd>Telescope undo<CR>", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<leader>sv", "<C-w>v", {
	noremap = true,
	desc = "split vertical",
})
vim.api.nvim_set_keymap("n", "<leader>sh", "<C-w>s", {
	noremap = true,
	desc = "split horizontal",
})
vim.api.nvim_set_keymap("n", "<leader>sx", ":close<CR>", {
	noremap = true,
	desc = "close window",
})

vim.api.nvim_set_keymap("n", "<leader>bd", ":bd<CR><CR>", {
	noremap = true,
	desc = "close buffer",
})

vim.api.nvim_set_keymap("v", "y", "ygv<esc>", {
	noremap = true,
})

vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", {
	noremap = true,
})

vim.api.nvim_set_keymap("n", "<Tab>", ":bnext<CR>", {
	noremap = true,
	silent = true,
})
vim.api.nvim_set_keymap("n", "<S-Tab>", ":bprev<CR>", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<C-j>", ":m .+1<CR>==", { -- move line down
	noremap = true,
	silent = true,
})
vim.api.nvim_set_keymap("n", "<C-k>", ":m .-2<CR>==", { -- move line up
	noremap = true,
	silent = true,
})
vim.api.nvim_set_keymap("i", "<C-j>", "<Esc>:m .+1<CR>==gi", {
	noremap = true,
	silent = true,
})
vim.api.nvim_set_keymap("i", "<C-k>", "<Esc>:m .-2<CR>==gi", {
	noremap = true,
	silent = true,
})
vim.api.nvim_set_keymap("v", "<C-j>", ":m '>+1<CR>gv", {
	noremap = true,
	silent = true,
})
vim.api.nvim_set_keymap("v", "<C-k>", ":m '<-2<CR>gv", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("v", "y", "ygv", {
	noremap = true,
})
vim.api.nvim_set_keymap("v", ">", ">gv", {
	noremap = true,
})
vim.api.nvim_set_keymap("v", "<", "<gv", {
	noremap = true,
})

vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true })

vim.keymap.set("x", "<leader>p", '"_dP') -- Paste without copying
vim.keymap.set("n", "<leader>ra", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

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

vim.api.nvim_set_keymap("n", "<leader>ss", "<cmd>Telescope session-lens<cr>", { noremap = true, silent = true })

vim.api.nvim_set_keymap(
	"n",
	"<leader>fw",
	[[:lua require('telescope.builtin').live_grep({ default_text = vim.fn.expand('<cword>') })<CR>]],
	{
		noremap = true,
		silent = true,
		desc = "find word under cursor",
	}
)

vim.api.nvim_set_keymap(
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

vim.api.nvim_set_keymap(
	"n",
	"<leader>o",
	"<CMD>SymbolsOutline<CR>",
	{ desc = "Symbols outline", noremap = true, silent = true }
)