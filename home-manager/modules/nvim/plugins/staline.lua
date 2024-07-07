require("staline").setup({
	sections = {
		left = { "mode" },
		mid = { "file_name", "lsp" },
		right = { "", "cwd", "branch" },
	},
	mode_colors = {
		i = "#273C2C",
		n = "#dfaf87",
		c = "#af5f00",
		v = "#2B2D42",
		V = "#2B2D42",
	},
	mode_icons = {
		n = "  NORMAL ",
		i = "  INSERT ",
		c = "  COMMAND ",
		v = "  VISUAL ",
		V = "  VISUAL ",
	},
	defaults = {
		true_colors = true,
		branch_symbol = " ",
	},
})
