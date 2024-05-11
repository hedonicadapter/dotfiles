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
						CursorLine = { bg = "#8fbf7f" },
						CursorLineNr = { fg = "#000000", bg = "#8fbf7f" },
					},
				},
				-- delete
				d = {
					winhl = {
						CursorLine = { bg = "#34302C" },
						CursorLineNr = { fg = "#867462", bg = "#34302C" },
					},
				},
				-- yank
				y = {
					winhl = {
						CursorLine = { bg = "#7D2A2F" },
						CursorLineNr = { fg = "#867462", bg = "#7D2A2F" },
					},
				},
			},
		},
		i = {
			winhl = {
				CursorLine = { bg = "#d4be98" },
				CursorLineNr = { fg = "#000000", bg = "#d4be98" },
			},
		},
		c = {
			winhl = {
				CursorLine = { bg = "#8fbf7f" },
				CursorLineNr = { fg = "#000000", bg = "#8fbf7f" },
			},
		},
		n = {
			winhl = {
				CursorLine = { bg = "#403A36" }, -- Slightly lighter gray
				CursorLineNr = { fg = "#867462", bg = "#403A36" },
			},
		},
		-- visual
		[{ "v", "V", "\x16" }] = {
			winhl = {
				CursorLineNr = { fg = "#867462" },
				Visual = { bg = "#273142" }, -- Dark blue
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
				CursorLineNr = { fg = "#867462", bg = "#7D2A2F" },
			},
		},
	},
}
