---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local autok8s = require("auto-k8s")

describe("auto-k8s.get_spec", function()
	it("can get spec for cnpg", function()
		local url = autok8s.find_definition_url({ kind = "Cluster", api_version = "postgresql.cnpg.io/v1" })
		vim.print(url)
	end)
	it("can get spec for deployment", function()
		local url = autok8s.find_definition_url({ kind = "Deployment", api_version = "apps/v1" })
		vim.print(url)
	end)
end)
