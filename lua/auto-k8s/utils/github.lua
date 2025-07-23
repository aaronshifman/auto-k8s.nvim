local curl = require("plenary.curl")
local config = require("auto-k8s.config")

local M = {}

---Fetch all json filepaths in the repo (blobs)
---@param url string url to pull the definition lists from
---@param strip_prefix boolean If there's a leading prefix should we strip it off (yes for native resources)
---@return string[] list of file paths
function M.fetch_names(url, strip_prefix)
	local response = curl.get(url, {
		headers = config.options.github_headers,
		query = { recursive = 1 },
	})
	local body = vim.fn.json_decode(response.body)
	local files = {}

	local source = body.tree or body
	for _, data in ipairs(source) do
		if data.path:match("%.json$") then
			if strip_prefix then
				table.insert(files, data.path:match("([^/]+)$"))
			else
				table.insert(files, data.path)
			end
		end
	end
	return files
end

return M
