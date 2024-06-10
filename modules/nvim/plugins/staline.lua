require("staline").setup({
	sections = {
		left = { "mode", "  ", "branch", "  ", "lsp" },
		mid = { "cwd" },
		right = { "file_name" },
	},
	mode_colors = {
		i = "#87875f",
		n = "#dfdfaf",
		c = "#af5f00",
		v = "#87afaf",
		V = "#87afaf",
	},
	mode_icons = {
		n = " NORMAL ",
		i = " INSERT ",
		c = " COMMAND ",
		v = " VISUAL ",
		V = " VISUAL ",
	},
	defaults = {
		true_colors = true,
		branch_symbol = " ",
	},
})
