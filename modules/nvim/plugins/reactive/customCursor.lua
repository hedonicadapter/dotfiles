return {
	name = "customCursorLine",
	init = function()
		vim.opt.cursorline = true
	end,
	-- static = {
	-- 	winhl = {
	-- 		inactive = {
	-- 			CursorLine = { bg = "#202020" },
	-- 			CursorLineNr = { fg = "#b0b0b0", bg = "#202020" },
	-- 		},
	-- 	},
	-- },
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
						CursorLine = { bg = "#ffdf87" },
						CursorLineNr = { fg = "#ffdf87", bg = "#ffdf87" },
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
						CursorLine = { bg = "#875f5f" },
						CursorLineNr = { fg = "#875f5f", bg = "#875f5f" },
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
				Cursor = { bg = "#87875f" },
			},
		},
		c = {
			winhl = {
				CursorLine = { bg = "#af5f00" },
				CursorLineNr = { fg = "#af5f00", bg = "#af5f00" },
			},
		},
		n = {
			winhl = {
				CursorLine = { bg = "#dfaf87" },
				CursorLineNr = { fg = "#dfaf87", bg = "#dfaf87" },
			},
			hl = {
				Cursor = { bg = "#dfaf87" },
			},
		},
		-- visual
		[{ "v", "V", "\x16" }] = {
			winhl = {
				CursorLineNr = { fg = "#2B2D42" },
				Visual = { bg = "#2B2D42" },
			},
			hl = {
				Cursor = { bg = "#87afaf" },
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
				CursorLine = { bg = "#af5f5f" },
				CursorLineNr = { fg = "#af5f5f", bg = "#af5f5f" },
			},
		},
	},
}
