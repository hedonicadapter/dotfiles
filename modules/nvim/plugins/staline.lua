require("staline").setup({
	sections = {
		left = { "mode", "  ", "cwd", " ", "branch" },
		mid = { "lsp" },
		right = { "file_name", "  ", "line_column" },
	},
	mode_colors = {
		i = "#273C2C",
		n = "#dfaf87",
		c = "#af5f00",
		v = "#2B2D42",
		V = "#2B2D42",
	},
	mode_icons = {
		n = " NORMAL ",
		i = " INSERT ",
		c = " COMMAND ",
		v = " VISUAL ",
		V = " VISUAL ",
	},
	defaults = {
		true_colors = true,
		branch_symbol = " ",
		line_column = "%l",
	},
})
