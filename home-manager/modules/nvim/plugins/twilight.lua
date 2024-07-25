require("twilight").setup({

	dimming = {
		alpha = 0.5,
	},
	treesitter = true,
})

vim.api.nvim_exec(
	[[
    au BufEnter * TwilightEnable
]],
	false
)
