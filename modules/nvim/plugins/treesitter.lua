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
