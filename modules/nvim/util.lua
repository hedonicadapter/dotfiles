local lfs = require("lfs")

local M = {}

function M.getFilesInDirectory(directory)
	local files = {}
	for filename in lfs.dir(directory) do
		if filename ~= "." and filename ~= ".." then
			local path = directory .. "/" .. filename
			local attr = lfs.attributes(path)
			if attr.mode == "file" then
				local newFilename = string.gsub(filename, "%%", "/")
				local fileObject = { name = newFilename }
				table.insert(files, fileObject)
			end
		end
	end
	return files
end

return M
