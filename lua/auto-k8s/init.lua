local config = require("auto-k8s.config")
local schema = require("auto-k8s.schema")

local M = {}

---Setup the plugin with user configuration
---@param opts? table
function M.setup(opts)
	config.setup(opts)
	schema.init_cache()
end

---Extract resource spec from YAML content
---@param contents string
---@return table|nil
function M.extract_resource_spec(contents)
	return schema.extract_resource_spec(contents)
end

---Find schema definition URL for the resource
---@param api_version string
---@param kind string
---@return string|nil
function M.find_definition_url(api_version, kind)
	return schema.find_definition_url(api_version, kind)
end

return M
