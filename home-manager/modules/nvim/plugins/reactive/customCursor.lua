return {
	name = "customCursorLine",
	init = function()
		vim.opt.cursorline = true
	end,
	modes = {
		no = {
			operators = {
				-- switch case
				[{ "gu", "gU", "g~", "~" }] = {
					winhl = {
						CursorLine = { bg = "#292522" },
						CursorLineNr = { fg = "#867462", bg = "#292522" },
					},
				},
				-- change
				c = {
					winhl = {
						CursorLine = { bg = vim.g.colors_yellow },
						CursorLineNr = { fg = vim.g.colors_yellow, bg = vim.g.colors_yellow },
					},
				},
				-- delete
				d = {
					winhl = {
						CursorLine = { bg = "#34302C" },
						CursorLineNr = { fg = "#34302C", bg = "#34302C" },
					},
				},
				-- yank
				y = {
					winhl = {
						CursorLine = { bg = vim.g.colors_burgundy },
						CursorLineNr = { fg = vim.g.colors_burgundy, bg = vim.g.colors_burgundy },
					},
				},
			},
		},
		i = {
			winhl = {
				CursorLine = { bg = "#273C2C" },
				CursorLineNr = { fg = "#273C2C", bg = "#273C2C" },
			},
			hl = {
				Cursor = { bg = vim.g.colors_green },
			},
		},
		c = {
			winhl = {
				CursorLine = { bg = vim.g.colors_orange },
				CursorLineNr = { fg = vim.g.colors_orange, bg = vim.g.colors_orange },
			},
		},
		n = {
			winhl = {
				CursorLine = { bg = vim.g.colors_beige },
				CursorLineNr = { fg = vim.g.colors_beige, bg = vim.g.colors_beige },
			},
			hl = {
				Cursor = { bg = vim.g.colors_beige },
			},
		},
		-- visual
		[{ "v", "V", "\x16" }] = {
			winhl = {
				CursorLineNr = { fg = "#2B2D42" },
				Visual = { bg = "#2B2D42" },
			},
			hl = {
				Cursor = { bg = vim.g.colors_cyan },
			},
		},
		-- select
		[{ "s", "S", "\x13" }] = {
			winhl = {
				CursorLineNr = { fg = "#273142" },
				Visual = { bg = "#422741" },
			},
		},
		-- replace
		R = {
			winhl = {
				CursorLine = { bg = vim.g.colors_red },
				CursorLineNr = { fg = vim.g.colors_red, bg = vim.g.colors_red },
			},
		},
	},
}
