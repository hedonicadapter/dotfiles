require("staline").setup({
	sections = {
		left = { "mode", "  ", "branch", "  ", "lsp" },
		mid = { "cwd" },
		right = { "file_name" },
	},
	mode_colors = {
		i = "#6c782e",
		n = "#4c7a5d",
		c = "#c35e0a",
		v = "#45707a",
		V = "#45707a",
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
