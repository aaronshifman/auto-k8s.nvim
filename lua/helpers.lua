local M = {}
M.xor = function(x, y)
	return (x or y) and not (x and y)
end

return M
