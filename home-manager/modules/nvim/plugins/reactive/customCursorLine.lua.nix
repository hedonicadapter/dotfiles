{outputs, ...}: let
  lua = ''
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
    						CursorLine = { bg = "${outputs.darken outputs.colors_opaque.black 0.5}" },
    						CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.beige 0.5}", bg = "${outputs.darken outputs.colors_opaque.black 0.5}" },
    					},
    				},
    				-- change
    				c = {
    					winhl = {
    						CursorLine = { bg = "${outputs.darken outputs.colors_opaque.yellow 0.5}" },
    						CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.yellow 0.5}", bg = "${outputs.darken outputs.colors_opaque.yellow 0.5}" },
    					},
    				},
    				-- yank
    				y = {
    					winhl = {
    						CursorLine = { bg = "${outputs.darken outputs.colors_opaque.burgundy 0.5}" },
    						CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.burgundy 0.5}", bg = "${outputs.darken outputs.colors_opaque.burgundy 0.5}" },
    					},
    				},
    			},
    		},
    		i = {
    			winhl = {
    				CursorLine = { bg = "${outputs.darken outputs.colors_opaque.green 0.5}" },
    				CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.green 0.5}", bg = "${outputs.darken outputs.colors_opaque.green 0.5}" },
    			},
    			hl = {
    				Cursor = { bg = "${outputs.darken outputs.colors_opaque.green 0.5}" },
    			},
    		},
    		c = {
    			winhl = {
    				CursorLine = { bg = "${outputs.darken outputs.colors_opaque.orange 0.5}" },
    				CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.orange 0.5}", bg = "${outputs.darken outputs.colors_opaque.orange 0.5}" },
    			},
    		},
    		n = {
    			winhl = {
    				CursorLine = { bg = "${outputs.darken outputs.colors_opaque.white_dim 0.5}" },
    				CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.white_dim 0.5}", bg = "${outputs.darken outputs.colors_opaque.white_dim 0.5}" },
    			},
    			hl = {
    				Cursor = { bg = "${outputs.darken outputs.colors_opaque.white_dim 0.5}" },
    			},
    		},
    		-- visual
    		[{ "v", "V", "\x16" }] = {
    			winhl = {
    				CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.blue 0.5}" },
    				Visual = { bg = "${outputs.darken outputs.colors_opaque.blue 0.5}" },
    			},
    			hl = {
    				Cursor = { bg = "${outputs.darken outputs.colors_opaque.cyan 0.5}" },
    			},
    		},
    		-- select
    		[{ "s", "S", "\x13" }] = {
    			winhl = {
    				CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.blue 0.5}" },
    				Visual = { bg = "${outputs.darken outputs.colors_opaque.blue 0.5}" },
    			},
    		},
    		-- replace
    		R = {
    			winhl = {
    				CursorLine = { bg = "${outputs.darken outputs.colors_opaque.red 0.5}" },
    				CursorLineNr = { fg = "${outputs.darken outputs.colors_opaque.red 0.5}", bg = "${outputs.darken outputs.colors_opaque.red 0.5}" },
    			},
    		},
    	},
    }
  '';
in
  lua
