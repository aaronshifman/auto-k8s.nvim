local config = require("auto-k8s.config")
local schema = require("auto-k8s.schema")

local test_cache_dir = vim.fn.getcwd() .. "/test_cache"

-- Ensure test cache directory exists
vim.fn.mkdir(test_cache_dir, "p")

config.setup({
    cache_dir = test_cache_dir,
    k8s_version = "1.31.2"
})

-- Initialize schema cache
schema.init_cache()

-- Export for tests
return {
    schema = schema
}