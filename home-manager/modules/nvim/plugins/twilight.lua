require("twilight").setup({
	dimming = {
		alpha = 0.4,
	},
	treesitter = true,
})

vim.api.nvim_exec(
	[[
    au BufEnter * TwilightEnable
]],
	false
)
