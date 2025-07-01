---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local autok8s = require("auto-k8s")
local helpers = require("tests.helpers")

describe("auto-k8s.fetch-crds", function()
	it("fetch-crds gets a bunch of crds", function()
		local crd_list = autok8s.schema_cache.crds
		assert.is.True(#crd_list > 100) -- not sure how many - but should be a "bunch"
		assert.is.True(helpers.contains(crd_list, "postgresql.cnpg.io/cluster_v1.json"))
		assert.is.False(helpers.contains(crd_list, "apps/deployment_v1.json"))
	end)

	it("fetch-resources gets a bunch of resources", function()
		local crd_list = autok8s.schema_cache.resources
		assert.is.True(#crd_list > 100) -- not sure how many - but should be a "bunch"
		assert.is.False(helpers.contains(crd_list, "postgresql.cnpg.io/cluster_v1.json"))
		assert.is.True(helpers.contains(crd_list, "deployment.json"))
	end)
end)

describe("auto-k8s.map-resource-to-crds", function()
	it("CNPG is mappable", function()
		assert.is.True(autok8s.check_crd_validity("postgresql.cnpg.io/cluster_v1.json"))
	end)
	it("Deployment not mappable", function()
		assert.is.False(autok8s.check_crd_validity("apps/deployment_v1.json"))
	end)
end)

describe("auto-k8s.map-resource-to-resource-description", function()
	it("CNPG is not", function()
		assert.is.False(autok8s.check_resource_validity("cluster"))
	end)
	it("Deployment is mappable", function()
		assert.is.True(autok8s.check_resource_validity("deployment"))
		assert.is.True(autok8s.check_resource_validity("Deployment"))
	end)
	it("Service is mappable", function()
		assert.is.True(autok8s.check_resource_validity("service"))
	end)
	it("netpol is mappable", function()
		assert.is.True(autok8s.check_resource_validity("networkpolicy"))
	end)
end)
