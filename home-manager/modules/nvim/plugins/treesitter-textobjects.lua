require("nvim-treesitter.configs").setup({
	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				["ia"] = "@parameter.inner",
				["aa"] = "@parameter.outer",

				["if"] = "@function.inner",
				["af"] = "@function.outer",

				["ic"] = "@conditional.inner",
				["ac"] = "@conditional.outer",

				["il"] = "@loop.inner",
				["al"] = "@loop.outer",
			},
		},
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
