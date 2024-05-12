-- require("mini.sessions").setup({
-- 	directory = "~/.config/nvim/sessions",
-- 	file = "''",
-- })
local starter = require("mini.starter")

function merge_tables(t1, t2)
	for k, v in ipairs(t2) do
		table.insert(t1, v)
	end
	return t1
end

function getFilesInDirectory(directory)
	local files = {}
	for dir in io.popen("ls -pa " .. directory .. " | grep -v /"):lines() do
		local filename_withoutpercentage = string.gsub(dir, "%%", "/")
		local filename = string.gsub(filename_withoutpercentage, "%.vim", "")
		local fileObject = { name = filename }

		table.insert(files, fileObject)
	end
	return files
end

local my_items = function()
	local sessions = getFilesInDirectory("~/.local/share/nvim/sessions")

	for i, fileObject in ipairs(sessions) do
		fileObject.action = "lua require('auto-session.session-lens.actions').functions.RestoreSession('"
			.. fileObject.name
			.. "')"
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
require("mini.move").setup({
	mappings = {
		down = "J",
		up = "K",
	},
})
require("mini.indentscope").setup()
