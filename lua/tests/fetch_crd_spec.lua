---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local helpers = require("tests.helpers")
local test_env = {}

describe("auto-k8s.fetch-crds", function()
    before_each(function()
        test_env.schema = require("auto-k8s.schema")
        test_env.crd = require("auto-k8s.schema.crd")
        test_env.resource = require("auto-k8s.schema.resource")
        test_env.schema.init_cache()
    end)

    it("fetch-crds gets a bunch of crds", function()
        local crds = test_env.schema.cache.crds
        assert.is.True(#crds > 100) -- not sure how many - but should be a "bunch"
        assert.is.True(helpers.contains(crds, "postgresql.cnpg.io/cluster_v1.json"))
        assert.is.False(helpers.contains(crds, "apps/deployment_v1.json"))
    end)

    it("fetch-resources gets a bunch of resources", function()
        local resources = test_env.schema.cache.resources
        assert.is.True(#resources > 100) -- not sure how many - but should be a "bunch"
        assert.is.False(helpers.contains(resources, "postgresql.cnpg.io/cluster_v1.json"))
        assert.is.True(helpers.contains(resources, "deployment.json"))
    end)
end)

describe("auto-k8s.map-resource-to-crds", function()
    before_each(function()
        test_env.schema = require("auto-k8s.schema")
        test_env.crd = require("auto-k8s.schema.crd")
        test_env.resource = require("auto-k8s.schema.resource")
        test_env.schema.init_cache()
    end)

    it("CNPG is mappable", function()
        assert.is.True(test_env.crd.check_crd_validity("postgresql.cnpg.io/cluster_v1.json", test_env.schema.cache.crds))
    end)
    it("Deployment not mappable", function()
        assert.is.False(test_env.crd.check_crd_validity("apps/deployment_v1.json", test_env.schema.cache.crds))
    end)
end)

describe("auto-k8s.map-resource-to-resource-description", function()
    before_each(function()
        test_env.schema = require("auto-k8s.schema")
        test_env.crd = require("auto-k8s.schema.crd")
        test_env.resource = require("auto-k8s.schema.resource")
        test_env.schema.init_cache()
    end)

    it("CNPG is not", function()
        assert.is.False(test_env.resource.check_resource_validity("cluster", test_env.schema.cache.resources))
    end)
    it("Deployment is mappable", function()
        assert.is.True(test_env.resource.check_resource_validity("deployment", test_env.schema.cache.resources))
        assert.is.True(test_env.resource.check_resource_validity("Deployment", test_env.schema.cache.resources))
    end)
    it("Service is mappable", function()
        assert.is.True(test_env.resource.check_resource_validity("service", test_env.schema.cache.resources))
    end)
    it("netpol is mappable", function()
        assert.is.True(test_env.resource.check_resource_validity("networkpolicy", test_env.schema.cache.resources))
    end)
end)