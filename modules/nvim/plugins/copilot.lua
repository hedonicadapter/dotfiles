require("copilot").setup({
	suggestion = {
		auto_trigger = true,
		keymap = {
			accept = "<C-Tab>",
		},
	},
})

vim.api.nvim_exec(
	[[
          au VimEnter * Copilot auth
        ]],
	false
)

