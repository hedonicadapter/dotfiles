require("nvim-treesitter.configs").setup({
	textobjects = {
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["<C-l>"] = { query = "@function.outer" },
			},
			goto_previous_start = {
				["<C-r>"] = { query = "@function.outer" },
			},
		},
	},
})
