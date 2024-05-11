require("staline").setup({
	sections = {
		left = { "mode", "  ", "branch", "  ", "lsp" },
		mid = { "cwd" },
		right = { "file_name" },
	},
	mode_colors = {
		i = "#d4be98",
		n = "#84a598",
		c = "#8fbf7f",
		v = "#fc802d",
	},
	defaults = {
		true_colors = true,
		branch_symbol = " ",
	},
})
