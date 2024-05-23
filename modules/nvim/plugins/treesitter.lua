require("nvim-treesitter.install").compilers = { "gcc" }
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	autotag = { enable = true },
	indent = { enable = true },
	incremental_selection = { enable = true },

	-- ensure_installed = {
	-- "astro",
	-- "bash",
	-- "bicep",
	-- "c_sharp",
	-- "css",
	-- "dockerfile",
	-- "go",
	-- "gitignore",
	-- "html",
	-- "json",
	-- "typescript",
	-- "tsx",
	-- "javascript",
	-- "jsdoc",
	-- "lua",
	-- "nix",
	-- "sql",
	-- "scss",
	-- "terraform",
	-- "vim",
	-- "yaml",
	-- },
	-- parser_install_dir = "~/.config/nvim/parsers"
})

-- Disable the } keybind
vim.api.nvim_set_keymap(
	"n",
	"}",
	"<cmd>lua require'nvim-treesitter.textobjects.move'.goto_next_start()<CR>",
	{ noremap = true }
)
--
-- -- Disable the { keybind
-- vim.api.nvim_set_keymap("n", "{", ts_move.goto_previous_start, { noremap = true })
