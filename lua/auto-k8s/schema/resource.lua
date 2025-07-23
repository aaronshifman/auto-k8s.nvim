local config = require("auto-k8s.config")
local M = {}

---Validate for the resource's existence
---@param resource_name string Name of the resource
---@param resources string[] List of available resources
---@return boolean
function M.check_resource_validity(resource_name, resources)
	for _, resource in ipairs(resources) do
		if resource == resource_name:lower() .. ".json" then
			return true
		end
	end
	return false
end

---Get resource schema URL
---@param kind string The kind of the resource
---@return string
function M.get_schema_url(kind)
	return string.format(
		"https://raw.githubusercontent.com/%s/refs/heads/%s/v%s/%s.json",
		config.options.resource_catalog,
		config.options.resource_catalog_branch,
		config.options.k8s_version,
		kind:lower()
	)
end

return M
