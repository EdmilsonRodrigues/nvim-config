
local M = {}
 

function M.toggle_comment()
  	local line = vim.api.nvim_get_current_line()
	local identation = 0


	local i = 1
	while i <= #line and string.sub(line, i, i) == " " do
		identation = identation + 1
		i = i + 1
	
	end

	while i <= #line and string.sub(line, i, i) == "\t" do
		identation = identation + 4
		i = i +1
	end

	local trimmed_line = string.sub(line, identation + 1)


	-- Remove python comment
	if string.sub(trimmed_line, 1, 1) == "#" then
		if string.sub(trimmed_line, 2, 2) == " " then
			trimmed_line = string.sub(trimmed_line, 3)
		else
			trimmed_line = string.sub(trimmed_line, 2)
		end
		
		line = string.rep(" ", identation) .. trimmed_line
		
	-- Add python comment
	else
		line = string.rep(" ", identation) .. "# " .. trimmed_line
	end
	
	vim.api.nvim_set_current_line(line)
end

return M

