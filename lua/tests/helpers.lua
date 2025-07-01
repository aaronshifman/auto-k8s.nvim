M = {}
---Check if an "array-like" table contains a value
---@param tab table
---@param val any
---@return boolean
M.contains = function(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

M.get_test_dir = function()
	local info = debug.getinfo(1, "S")
	return info.source:sub(2):match("(.*/)")
end

return M
