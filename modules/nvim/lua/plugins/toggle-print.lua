local M = {}

M.print_statements = {
	lua = "print('%s')",
	python = "print('%s')",
	javascript = "console.log('%s')",
	javascriptreact = "console.log('%s')",
	typescript = "console.log('%s')",
	typescriptreact = "console.log('%s')",
}

function M.tbl_length(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

function M.get_visual_selection()
	-- this will exit visual mode
	-- use 'gv' to reselect the text
	local _, csrow, cscol, cerow, cecol
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "" then
		-- if we are in visual mode use the live position
		_, csrow, cscol, _ = unpack(vim.fn.getpos("."))
		_, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
		if mode == "V" then
			-- visual line doesn't provide columns
			cscol, cecol = 0, 999
		end
		-- exit visual mode
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	else
		-- otherwise, use the last known visual position
		_, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
		_, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
	end
	-- swap vars if needed
	if cerow < csrow then
		csrow, cerow = cerow, csrow
	end
	if cecol < cscol then
		cscol, cecol = cecol, cscol
	end
	local lines = vim.fn.getline(csrow, cerow)
	-- local n = cerow-csrow+1
	local n = M.tbl_length(lines)
	if n <= 0 then
		return ""
	end
	lines[n] = string.sub(lines[n], 1, cecol)
	lines[1] = string.sub(lines[1], cscol)
	return table.concat(lines, "\n")
end

function M.toggle_print()
	local buf = vim.api.nvim_get_current_buf()
	local buf_lang = vim.bo[buf].filetype

	local print_stmt = M.print_statements[buf_lang]
	if not print_stmt then
		print("No print statement defined for this language")
		return
	end

	local selection = M.get_visual_selection()

	selection = selection:match("^%s*(.-)%s*$")
	local wrapped_print_stmt = string.format(print_stmt, selection)

	local s_pos = vim.fn.getpos("'<")
	local e_pos = vim.fn.getpos("'>")

	vim.api.nvim_buf_set_text(buf, s_pos[2] - 1, s_pos[3] - 1, e_pos[2] - 1, e_pos[3], { wrapped_print_stmt })
end

return M
