local config = require("auto-k8s.config")
local M = {}

---Convert spec to CRD filepath format
---@param api_version string
---@param kind string
---@return string|nil
function M.convert_to_filepath(api_version, kind)
	if not api_version or not kind then
		return nil
	end

	-- apps/v1 -> apps, v1
	local api, version = api_version:match("([^/]+)/([^/]+)")

	if not version or not api then
		return nil
	end

	return api .. "/" .. kind:lower() .. "_" .. version .. ".json"
end

---Check if CRD exists in available CRDs
---@param filepath string Expected filepath
---@param crds string[] List of available CRDs
---@return boolean
function M.check_crd_validity(filepath, crds)
	for _, crd in ipairs(crds) do
		if crd == filepath then
			return true
		end
	end
	return false
end

---Get CRD schema URL
---@param filepath string The CRD filepath
---@return string
function M.get_schema_url(filepath)
	return string.format(
		"https://raw.githubusercontent.com/%s/%s/%s",
		config.options.crd_catalog,
		config.options.schema_catalog_branch,
		filepath
	)
end

return M
