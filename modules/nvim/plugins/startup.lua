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
		local fileObject = { filename }

		table.insert(files, fileObject)
	end
	return files
end

local my_items = function()
	local sessions = getFilesInDirectory("~/.local/share/nvim/sessions")
	local result = {}

	for i, fileObject in ipairs(sessions) do
		local command = "lua require('auto-session.session-lens.actions').functions.RestoreSession('"
			.. fileObject[1]
			.. "')"
		local displayed_command_name = fileObject[1]
		local mapping = "<leader>" .. i

		table.insert(result, { displayed_command_name, command, mapping })
	end
	return result
end

require("startup").setup({
	section_1 = {
		type = "mapping",
		align = "right",
		title = "Sessions",
		margin = "2",
		content = my_items(),
	},
	-- section_2 =
	options = {
		mapping_keys = true, -- display mapping (e.g. <leader>ff)

		-- if < 1 fraction of screen width
		-- if > 1 numbers of column
		cursor_column = 0.5,
		empty_lines_between_mappings = true, -- add an empty line between mapping/commands
		disable_statuslines = true, -- disable status-, buffer- and tablines
		paddings = { 1 }, -- amount of empty lines before each section (must be equal to amount of sections)
	},
	mappings = {
		execute_command = "<CR>",
		open_file = "o",
		open_file_split = "<c-o>",
		open_section = "<TAB>",
		open_help = "?",
	},
	colors = {
		background = "#1f2227",
		folded_section = "#56b6c2", -- the color of folded sections
		-- this can also be changed with the `StartupFoldedSection` highlight group
	},
	parts = { "section_1" }, -- all sections in order
})
