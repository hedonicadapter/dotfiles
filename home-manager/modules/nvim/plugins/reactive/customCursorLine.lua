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
						CursorLine = { bg = vim.g.colors_black_opaque },
						CursorLineNr = { fg = "#867462", bg = vim.g.colors_black_opaque },
					},
				},
				-- change
				c = {
					winhl = {
						CursorLine = { bg = vim.g.colors_yellow_opaque },
						CursorLineNr = { fg = vim.g.colors_yellow_opaque, bg = vim.g.colors_yellow_opaque },
					},
				},
				-- yank
				y = {
					winhl = {
						CursorLine = { bg = vim.g.colors_burgundy_opaque },
						CursorLineNr = { fg = vim.g.colors_burgundy_opaque, bg = vim.g.colors_burgundy_opaque },
					},
				},
			},
		},
		i = {
			winhl = {
				CursorLine = { bg = vim.g.colors_green_opaque },
				CursorLineNr = { fg = vim.g.colors_green_opaque, bg = vim.g.colors_green_opaque },
			},
			hl = {
				Cursor = { bg = vim.g.colors_green_opaque },
			},
		},
		c = {
			winhl = {
				CursorLine = { bg = vim.g.colors_orange_opaque },
				CursorLineNr = { fg = vim.g.colors_orange_opaque, bg = vim.g.colors_orange_opaque },
			},
		},
		n = {
			winhl = {
				CursorLine = { bg = vim.g.colors_beige_opaque },
				CursorLineNr = { fg = vim.g.colors_beige_opaque, bg = vim.g.colors_beige_opaque },
			},
			hl = {
				Cursor = { bg = vim.g.colors_beige_opaque },
			},
		},
		-- visual
		[{ "v", "V", "\x16" }] = {
			winhl = {
				CursorLineNr = { fg = vim.g.colors_blue_opaque },
				Visual = { bg = vim.g.colors_blue_opaque },
			},
			hl = {
				Cursor = { bg = vim.g.colors_cyan_opaque },
			},
		},
		-- select
		[{ "s", "S", "\x13" }] = {
			winhl = {
				CursorLineNr = { fg = vim.g.colors_blue_opaque },
				Visual = { bg = vim.g.colors_blue_opaque },
			},
		},
		-- replace
		R = {
			winhl = {
				CursorLine = { bg = vim.g.colors_red_opaque },
				CursorLineNr = { fg = vim.g.colors_red_opaque, bg = vim.g.colors_red_opaque },
			},
		},
	},
}
