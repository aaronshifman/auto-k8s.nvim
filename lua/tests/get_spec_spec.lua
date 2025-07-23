---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local schema = require("auto-k8s.schema")

describe("auto-k8s.get_spec", function()
	it("can get spec for cnpg", function()
		local url = schema.find_definition_url("postgresql.cnpg.io/v1", "Cluster")
		vim.print(url)
	end)
	it("can get spec for deployment", function()
		local url = schema.find_definition_url("apps/v1", "Deployment")
		vim.print(url)
	end)
end)
