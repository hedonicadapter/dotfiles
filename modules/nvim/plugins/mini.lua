-- require("mini.sessions").setup({
-- 	directory = "~/.config/nvim/sessions",
-- 	file = "''",
-- })

local util = require("../util")
local starter = require("mini.starter")

local my_items = function()
	local sessions = util.getFilesInDirectory("~/.local/share/nvim/sessions")

	for i, fileObject in ipairs(sessions) do
		fileObject.action = "lua vim.api.nvim_command'RestoreSession " .. fileObject.name .. "'"
		fileObject.section = "Sessions"
	end
	return sessions
end

starter.setup({
	header = [[ 
            ⠀⠀⠀⠀⠀⢀⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣄⠀
            ⠀⠀⠀⠀⠀⣿⠓⠙⠻⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡷⣦⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠛⠁⠀⠀⣿⠀
            ⠀⠀⠀⠀⢸⠏⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⠀⠀⠀⢸⠀⠙⢷⡄⠀⠀⠀⢀⣴⠞⠉⠀⠀⠀⠀⠀⣿⠀
            ⠀⠀⠀⠠⡾⠀⠀⠀⠀⠀⠀⠈⠳⣄⣠⡶⠗⠒⠲⢾⡆⠀⠀⠿⣆⢀⣶⠟⠁⠀⠀⠀⠀⠀⠀⠀⣿⠀
            ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠲⠿⣥⣄⡀⠀⠀⠈⠁⠀⠀⠀⣹⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀
            ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠀
            ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⢀⣄⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠃⠀
            ⠀⠀⠀⢸⡇⠀⠀⠀⠀⢠⡿⠋⠈⢹⡇⠀⠀⠀⠀⠀⠀⠀⠘⡿⠋⠈⠙⢷⣄⠀⠀⠀⠀⠀⣸⡏⠀⠀
            ⠀⠀⠀⠀⢿⡀⠀⠀⢠⡟⠁⠀⢠⣿⣷⠀⠀⠀⠀⠀⠀⠀⢸⣿⡧⠀⠀⠀⢻⡆⠀⠀⠀⣴⠏⠀⠀⠀
            ⢀⡀⢀⣄⣘⣿⠂⠀⣾⠃⠀⠀⣾⣿⣿⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⢸⡇⠀⠀⠸⡯⠤⠤⢤⡆
            ⠘⢿⣏⡉⠀⠈⠀⢈⣿⠀⠀⠀⠸⣿⡿⠀⠀⠀⠀⠀⠀⠀⠈⠻⠇⠀⠀⠀⢸⡇⠀⠀⠀⠀⢀⣠⡾⠃
            ⠀⠀⠉⠻⠦⢤⡤⢀⡹⣿⣶⠄⠀⠈⠀⠈⠙⠛⠻⠇⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠿⠀⠀⠀⣟⠁⠀⠀
            ⠀⠀⠀⠀⢠⡿⠁⠈⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⣵⠀⠀⠀⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡆⠀⠀
            ⠀⠀⠀⢰⡟⢀⣀⣤⡀⠀⠀⠀⠀⠀⠐⠦⠤⠶⠛⠷⠴⠾⠋⠀⠀⠀⠀⢀⣀⣤⠾⠛⠳⠦⠤⠇⠀⠀
            ⠀⠀⠀⣾⡗⠛⠉⠈⠙⠳⠦⣤⣄⣀⣀⡀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣴⣶⡟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⢰⡿⠿⠿⠶⠶⠶⠾⠛⣿⣿⡍⠀⣤⣸⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⢠⣄⡀⠀⠀⠸⣷⡀⢠⣠⣄⢀⣄⣀⣿⣿⣿⣷⡿⠿⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠈⠻⣟⠓⠲⠲⠿⣷⣾⡿⠿⠿⠛⠛⠉⠉⠉⠀⠀⠀⠸⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣶⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠋⠝⠛⢺⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⣿]],
	items = { starter.sections.recent_files(), table.unpack(my_items()) },
	footer = " ",
})
require("mini.move").setup({
	mappings = {
		down = "J",
		up = "K",
	},
})
require("mini.indentscope").setup()
