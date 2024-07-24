require("toggleterm").setup({
	shell = "zsh",
	hide_numbers = false,
	shade_terminals = false,
	highlights = {
		Normal = {
			guibg = "NONE",
		},
		FloatBorder = {
			guifg = "NONE",
			guibg = "NONE",
		},
	},
})

vim.api.nvim_exec(
	[[
		autocmd TermOpen term://*toggleterm* startinsert | normal! A
		autocmd TermLeave term://*toggleterm* stopinsert
	]],
	false
)

vim.api.nvim_set_keymap("n", "<C-Space>", ":ToggleTerm direction=vertical size=80 <CR>", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("t", "<C-Space>", "<cmd> :ToggleTerm<CR>", {
	noremap = true,
	silent = true,
})
vim.api.nvim_set_keymap("n", "<leader>cc", "<CMD>CopilotChatToggle<CR>", { desc = "Open Copilot Chat" })
vim.api.nvim_set_keymap("v", "<leader>cc", "<CMD>CopilotChatReview<CR>", { desc = "Open Copilot Chat" })
