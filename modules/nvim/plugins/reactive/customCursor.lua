return {
	name = "customCursorLine",
	init = function()
		vim.opt.cursorline = true
	end,
	static = {
		winhl = {
			inactive = {
				CursorLine = { bg = "#202020" },
				CursorLineNr = { fg = "#b0b0b0", bg = "#202020" },
			},
		},
	},
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
						CursorLine = { bg = "#d8a657" },
						CursorLineNr = { fg = "#d8a657", bg = "#d8a657" },
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
						CursorLine = { bg = "#654735" },
						CursorLineNr = { fg = "#654735", bg = "#654735" },
					},
				},
			},
		},
		i = {
			winhl = {
				CursorLine = { bg = "#6c782e" },
				CursorLineNr = { fg = "#6c782e", bg = "#6c782e" },
			},
		},
		c = {
			winhl = {
				CursorLine = { bg = "#c35e0a" },
				CursorLineNr = { fg = "#c35e0a", bg = "#c35e0a" },
			},
		},
		n = {
			winhl = {
				CursorLine = { bg = "#4c7a5d" },
				CursorLineNr = { fg = "#4c7a5d", bg = "#4c7a5d" },
			},
		},
		-- visual
		[{ "v", "V", "\x16" }] = {
			winhl = {
				CursorLineNr = { fg = "#45707a" },
				Visual = { bg = "#45707a" },
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
				CursorLine = { bg = "#7D2A2F" },
				CursorLineNr = { fg = "#7D2A2F", bg = "#7D2A2F" },
			},
		},
	},
}
