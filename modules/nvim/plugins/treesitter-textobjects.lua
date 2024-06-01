require("nvim-treesitter.configs").setup({
	textobjects = {
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				[")F"] = { query = "@function.inner" },
				[")C"] = { query = "@conditional.inner" },
				[")L"] = { query = "@loop.inner" },
				[")P"] = { query = "@parameter.inner" },
				[")B"] = { query = "@block.inner" },
				[")T"] = { query = "@textobject.inner" },
			},
			goto_previous_start = {
				["(F"] = { query = "@function.inner" },
				["(C"] = { query = "@conditional.inner" },
				["(L"] = { query = "@loop.inner" },
				["(P"] = { query = "@parameter.inner" },
				["(B"] = { query = "@block.inner" },
				["(T"] = { query = "@textobject.inner" },
			},
		},

		lsp_interop = {
			enable = true,
			border = "none",
			floating_preview_opts = {},
			peek_definition_code = {
				["<leader>pf"] = "@function.outer",
			},
		},
	},
})
