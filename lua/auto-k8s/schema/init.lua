local github = require("auto-k8s.utils.github")
local config = require("auto-k8s.config")
local file_cache = require("auto-k8s.cache.file")
local crd = require("auto-k8s.schema.crd")
local resource = require("auto-k8s.schema.resource")

local M = {}

---@class Schema
---@field crds string[]
---@field resources string[]
---@type Schema
M.cache = {
	crds = {},
	resources = {},
}

---Extract resource spec from YAML content
---@param contents string YAML content
---@return { api_version: string, kind: string }|nil
function M.extract_resource_spec(contents)
	local api_version = contents:match("apiVersion:%s*([%w%.%/%-]+)")
	local kind = contents:match("kind:%s*([%w%-]+)")

	if not api_version or not kind then
		return nil
	end

	return {
		api_version = api_version,
		kind = kind,
	}
end

---Find schema definition URL for the resource
---@param api_version string
---@param kind string
---@return string|nil
function M.find_definition_url(api_version, kind)
	if not api_version or not kind then
		return nil
	end

	-- Check CRD first
	local filepath = crd.convert_to_filepath(api_version, kind)
	if filepath and crd.check_crd_validity(filepath, M.cache.crds) then
		return crd.get_schema_url(filepath)
	end

	-- Check built-in resources
	if resource.check_resource_validity(kind, M.cache.resources) then
		return resource.get_schema_url(kind)
	end

	return nil
end

---Initialize schema cache
function M.init_cache()
	-- Setup CRDs cache
	local crds = file_cache.read_from_cache("crds")
	if not crds then
		local crd_url = config.options.github_base_api_url
			.. "/"
			.. config.options.crd_catalog
			.. "/git/trees/"
			.. config.options.schema_catalog_branch

		crds = github.fetch_names(crd_url, false)
		file_cache.cache_to_file("crds", crds)
	end
	M.cache.crds = crds

	-- Setup resources cache
	local resources = file_cache.read_from_cache("resources")
	if not resources then
		local resource_url = config.options.github_base_api_url
			.. "/"
			.. config.options.resource_catalog
			.. "/contents/v"
			.. config.options.k8s_version
			.. "/"

		resources = github.fetch_names(resource_url, true)
		file_cache.cache_to_file("resources", resources)
	end
	M.cache.resources = resources
end

return M
