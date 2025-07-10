local M = {}

local curl = require("plenary.curl")

---@class file_spec
---@field api_version string
---@field kind string

---@class schema_cache
---@field crds string[]
---@field resources string[]

local crd_catalog = "datreeio/CRDs-catalog"
local resource_catalog = "yannh/kubernetes-json-schema"
local schema_catalog_branch = "main"
local resource_catalog_branch = "master"
local github_base_api_url = "https://api.github.com/repos"
local k8s_version = "1.31.2"

local github_headers = {
	Accept = "application/vnd.github+json",
	["X-GitHub-Api-Version"] = "2022-11-28",
}

local crd_url = (github_base_api_url .. "/" .. crd_catalog .. "/git/trees/" .. schema_catalog_branch)
local resource_url = (github_base_api_url .. "/" .. resource_catalog .. "/contents" .. "/v" .. k8s_version .. "/")
local cachedir = "/Users/aaronshifman/Documents/auto-k8s.nvim/cache"

---Fetch all json filepaths in the repo (blobs)
---File format is api_version(without /v1)/kind_version.json
---@param url string url to pull the definition lists from
---@param strip_prefix boolean If there's a leading prefix should we strip it off (yes for native resources)
local fetch_names = function(url, strip_prefix)
	local response = curl.get(url, { headers = github_headers, query = { recursive = 1 } })
	local body = vim.fn.json_decode(response.body)
	local crds = {}

	local source = body.tree or body
	for _, data in ipairs(source) do
		if data.path:match("%.json$") then
			if strip_prefix then
				table.insert(crds, data.path:match("([^/]+)$"))
			else
				table.insert(crds, data.path)
			end
		end
	end
	return crds
end

---get the api version and kind from the file contents
---@param contents string
---@return file_spec
M.extract_resource_spec = function(contents)
	local api_version = contents:match("apiVersion:%s*([%w%.%/%-]+)")
	local kind = contents:match("kind:%s*([%w%-]+)")
	return {
		api_version = api_version,
		kind = kind,
	}
end

---Format the apiversion, kind into the datree filepath
---@param spec file_spec
---@return string
M.convert_crd_to_filepath = function(spec)
	if not spec.api_version or not spec.kind then
		-- TODO: warning or maybe check xor?
		return nil
	end
	-- apps/v1 -> apps, v1
	local api, version = spec.api_version:match("([^/]+)/([^/]+)")

	if not version or not api then
		-- TODO: ditto here
		return nil
	end

	return api .. "/" .. spec.kind:lower() .. "_" .. version .. ".json"
end

---Validate for the crd's existance
---@param expected_path string
---@return boolean
M.check_crd_validity = function(expected_path)
	for _, crd in ipairs(M.schema_cache.crds) do
		if crd == expected_path then
			return true
		end
	end
	return false
end

---Validate for the resources's existance
---@param resource_name string Name of the resource
---@return boolean
M.check_resource_validity = function(resource_name)
	for _, crd in ipairs(M.schema_cache.resources) do
		if crd == resource_name:lower() .. ".json" then
			return true
		end
	end
	return false
end

---Find the schema definition for the resource
---@param spec file_spec
---@return string
M.find_definition_url = function(spec)
	-- check crd
	local flat = M.convert_crd_to_filepath(spec)
	if M.check_crd_validity(flat) then
		return "https://raw.githubusercontent.com/" .. crd_catalog .. "/" .. schema_catalog_branch .. "/" .. flat
	elseif M.check_resource_validity(spec.kind) then
		return "https://raw.githubusercontent.com/"
				.. resource_catalog
				.. "/refs/heads/"
				.. resource_catalog_branch
				.. "/v"
				.. k8s_version
				.. "/"
				.. spec.kind:lower()
				.. ".json"
	else
		return nil
	end
end

---Cache CRDS to disk
---@param d string Cache directiory
---@param crds table crds
function cache_crds(d, crds)
	local file, err = io.open(d .. "/crds", "w")
	if not file then
		error(err)
	end
	for _, path in ipairs(crds) do
		file:write(path .. "\n")
	end
	file:flush()
	file:close()
end

---Cache resources to disk
---@param d string Cache directiory
---@param resources table resources
function cache_resources(d, resources)
	local file, err = io.open(d .. "/res", "w")
	if not file then
		error(err)
	end
	for _, path in ipairs(resources) do
		file:write(path .. "\n")
	end
	file:flush()
	file:close()
end

-- TODO: this goes in init
-- TODO: ttl
if M.schema_cache == nil then
	M.schema_cache = {}
	local file = io.open(cachedir .. "/crds", "r")
	if file == nil then
		M.schema_cache.crds = fetch_names(crd_url, false)
		cache_crds(cachedir, M.schema_cache.crds)
	else
		t = {}
		for line in file:lines() do
			table.insert(t, line)
		end
		M.schema_cache.crds = t
		file:close()
	end

	file = io.open(cachedir .. "/res", "r")
	if file == nil then
		M.schema_cache.resources = fetch_names(resource_url, true)
		cache_resources(cachedir, M.schema_cache.resources)
	else
		t = {}
		for line in file:lines() do
			table.insert(t, line)
		end
		M.schema_cache.resources = t
		file:close()
	end
end
return M
