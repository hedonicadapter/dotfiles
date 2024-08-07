require("staline").setup({
	sections = {
		left = { "mode" },
		mid = {},
		right = { "", "cwd", "branch" },
	},
	mode_colors = {
		i = vim.g["colors_green"],
		n = vim.g["colors_beige"],
		c = vim.g["colors_orange"],
		v = vim.g["colors_blue"],
		V = vim.g["colors_blue"],
	},
	mode_icons = {
		n = " ",
		i = " ",
		c = " ",
		v = " ",
		V = " ",
	},
	defaults = {
		true_colors = true,
		branch_symbol = " ",
	},
})
