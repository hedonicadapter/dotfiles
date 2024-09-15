{outputs, ...}: let
  lua = ''
    require("staline").setup({
    	sections = {
    		left = { "mode" },
    		mid = {},
    		right = { "", "cwd", "branch" },
    	},
    	mode_colors = {
    		i = "${outputs.colors.green}",
    		n = "${outputs.colors.beige}",
    		c = "${outputs.colors.orange}",
    		v = "${outputs.colors.blue}",
    		V = "${outputs.colors.blue}",
    	},
    	mode_icons = {
    		n = " ",
    		i = " ",
    		c = " ",
    		v = " ",
    		V = " ",
    	},
    	defaults = {
    		true_colors = true,
    		branch_symbol = " ",
    	},
    })
  '';
in
  lua
