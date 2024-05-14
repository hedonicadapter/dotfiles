require("staline").setup({
	sections = {
		left = { "mode", "  ", "branch", "  ", "lsp" },
		mid = { "cwd" },
		right = { "file_name" },
	},
	mode_colors = {
		i = "#867462",
		n = "#403A36",
		c = "#EBC06D",
		v = "#273142",
	},
	defaults = {
		true_colors = true,
		branch_symbol = " ",
	},
})
