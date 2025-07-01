---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local autok8s = require("auto-k8s")
local helper = require("tests.helpers")

describe("auto-k8s.parse_file", function()
	it("should handle empty file", function()
		assert.are.same(autok8s.extract_resource_spec("").apiversion, nil)
		assert.are.same(autok8s.extract_resource_spec("").kind, nil)
	end)

	it("should handle deployment", function()
		local file = io.open(helper.get_test_dir() .. "samples/deployment.yaml")
		local content = file:read("*a")
		local spec = autok8s.extract_resource_spec(content)
		assert.are.same(spec.api_version, "apps/v1")
		assert.are.same(spec.kind, "Deployment")
	end)

	it("should handle cnpg", function()
		local file = io.open(helper.get_test_dir() .. "samples/cnpg.yaml")
		local content = file:read("*a")
		local spec = autok8s.extract_resource_spec(content)
		assert.are.same(spec.api_version, "postgresql.cnpg.io/v1")
		assert.are.same(spec.kind, "Cluster")
	end)
end)

describe("auto-k8s.convert_crd_to_filepath", function()
	it("should handle borked definition", function()
		assert.are.same(autok8s.convert_crd_to_filepath({ api_version = "Foo" }), nil)
		assert.are.same(autok8s.convert_crd_to_filepath({ kind = "Bar" }), nil)
		assert.are.same(autok8s.convert_crd_to_filepath({}), nil)
	end)
	it("should handle deployments", function()
		-- TODO: this is a stupid test since deployment isn't a crd
		assert.are.same(
			autok8s.convert_crd_to_filepath({ api_version = "apps/v1", kind = "Deployment" }),
			"apps/deployment_v1.json"
		)
	end)
	it("should handle cnpg", function()
		assert.are.same(
			autok8s.convert_crd_to_filepath({ api_version = "postgresql.cnpg.io/v1", kind = "Cluster" }),
			"postgresql.cnpg.io/cluster_v1.json"
		)
	end)
end)
