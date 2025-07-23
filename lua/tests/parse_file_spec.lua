---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local schema = require("auto-k8s.schema")
local crd = require("auto-k8s.schema.crd")
local helper = require("tests.helpers")

describe("auto-k8s.parse_file", function()
	it("should handle empty file", function()
		local spec = schema.extract_resource_spec("")
		assert.are.same(spec, nil)
	end)

	it("should handle deployment", function()
		local file = io.open(helper.get_test_dir() .. "samples/deployment.yaml")
		local content = file:read("*a")
		local spec = schema.extract_resource_spec(content)
		assert.are.same(spec.api_version, "apps/v1")
		assert.are.same(spec.kind, "Deployment")
	end)

	it("should handle cnpg", function()
		local file = io.open(helper.get_test_dir() .. "samples/cnpg.yaml")
		local content = file:read("*a")
		local spec = schema.extract_resource_spec(content)
		assert.are.same(spec.api_version, "postgresql.cnpg.io/v1")
		assert.are.same(spec.kind, "Cluster")
	end)
end)

describe("auto-k8s.convert_crd_to_filepath", function()
	it("should handle borked definition", function()
		assert.are.same(crd.convert_to_filepath("Foo", nil), nil)
		assert.are.same(crd.convert_to_filepath(nil, "Bar"), nil)
		assert.are.same(crd.convert_to_filepath(nil, nil), nil)
	end)
	it("should handle deployments", function()
		-- TODO: this is a stupid test since deployment isn't a crd
		assert.are.same(
			crd.convert_to_filepath("apps/v1", "Deployment"),
			"apps/deployment_v1.json"
		)
	end)
	it("should handle cnpg", function()
		assert.are.same(
			crd.convert_to_filepath("postgresql.cnpg.io/v1", "Cluster"),
			"postgresql.cnpg.io/cluster_v1.json"
		)
	end)
end)
