local M = {}

---@class Config
---@field crd_catalog string
---@field resource_catalog string
---@field schema_catalog_branch string
---@field resource_catalog_branch string
---@field github_base_api_url string
---@field k8s_version string
---@field cache_dir string
---@field github_headers table

local default_config = {
	crd_catalog = "datreeio/CRDs-catalog",
	resource_catalog = "yannh/kubernetes-json-schema",
	schema_catalog_branch = "main",
	resource_catalog_branch = "master",
	github_base_api_url = "https://api.github.com/repos",
	k8s_version = "1.31.2",
	cache_dir = vim.fn.stdpath("cache") .. "/auto-k8s",
	github_headers = {
		Accept = "application/vnd.github+json",
		["X-GitHub-Api-Version"] = "2022-11-28",
	},
}

---@type Config
M.options = {}

---Setup configuration with user options
---@param opts? table
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", default_config, opts or {})

	-- Ensure cache directory exists
	vim.fn.mkdir(M.options.cache_dir, "p")
end

return M
