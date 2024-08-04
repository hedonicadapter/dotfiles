require("staline").setup({
	sections = {
		left = { "mode" },
		mid = {},
		right = { "", "cwd", "branch" },
	},
	mode_colors = {
		i = vim.g.colors_green_opaque,
		n = vim.g.colors_beige_opaque,
		c = vim.g.colors_orange_opaque,
		v = vim.g.colors_blue_opaque,
		V = vim.g.colors_blue_opaque,
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
