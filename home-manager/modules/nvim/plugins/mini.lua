local starter = require("mini.starter")
local getFilesInDirectory = require("utils").getFilesInDirectory

function merge_tables(t1, t2)
	for k, v in ipairs(t2) do
		table.insert(t1, v)
	end
	return t1
end

local my_items = function()
	local sessions = getFilesInDirectory("~/.local/share/nvim/sessions")

	for i, fileObject in ipairs(sessions) do
		fileObject.action = "lua require('auto-session.session-lens.actions').functions.RestoreSession('"
			.. fileObject.name
			.. "')"
		fileObject.name = i .. " " .. fileObject.name
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
	items = { my_items(), starter.sections.recent_files(5, false, false) },
	footer = " ",
})

vim.cmd("autocmd User MiniStarterOpened set showtabline=0")

require("mini.move").setup({
	mappings = {
		down = "J",
		up = "K",
	},
})
require("mini.ai").setup()
require("mini.clue").setup({ window = { delay = 250 } })
require("mini.cursorword").setup()
local map = require("mini.map")
map.setup({
	integrations = {
		map.gen_integration.builtin_search(),
		map.gen_integration.gitsigns(),
		map.gen_integration.diagnostic(),
	},
})
