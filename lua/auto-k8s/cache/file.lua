local config = require("auto-k8s.config")

local M = {}

---Cache data to disk
---@param filename string
---@param data string[]
function M.cache_to_file(filename, data)
	local file, err = io.open(config.options.cache_dir .. "/" .. filename, "w")
	if not file then
		error(err)
	end
	for _, item in ipairs(data) do
		file:write(item .. "\n")
	end
	file:flush()
	file:close()
end

---Read cache from disk
---@param filename string
---@return string[]|nil
function M.read_from_cache(filename)
	local file = io.open(config.options.cache_dir .. "/" .. filename, "r")
	if not file then
		return nil
	end

	local data = {}
	for line in file:lines() do
		table.insert(data, line)
	end
	file:close()
	return data
end

return M
