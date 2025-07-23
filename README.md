# auto-k8s.nvim

Automatically configure yamlls based on a k8s yaml file

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "aaronshifman/auto-k8s.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("auto-k8s").setup({
      -- Optional configuration here
    })
  end,
}
```

## Features

- Automatic YAML LSP configuration for Kubernetes files
- Dynamic schema detection based on file content

## Requirements

- Neovim >= 0.8.0
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- yaml-language-server

## Configuration

Below are all available configuration options with their default values:

```lua
require('auto-k8s').setup({
    -- GitHub repository containing CRD schemas
    crd_catalog = "datreeio/CRDs-catalog",
    
    -- GitHub repository containing Kubernetes resource schemas
    resource_catalog = "yannh/kubernetes-json-schema",
    
    -- Branch to use for CRD schemas
    schema_catalog_branch = "main",
    
    -- Branch to use for Kubernetes resource schemas
    resource_catalog_branch = "master",
    
    -- Base URL for GitHub API requests
    github_base_api_url = "https://api.github.com/repos",
    
    -- Kubernetes version for schema validation
    k8s_version = "1.31.2",
    
    -- Directory to store cached schemas
    -- Defaults to your Neovim cache directory + /auto-k8s
    cache_dir = vim.fn.stdpath("cache") .. "/auto-k8s",
    
    -- Headers used for GitHub API requests
    github_headers = {
        Accept = "application/vnd.github+json",
        ["X-GitHub-Api-Version"] = "2022-11-28",
    },
})
```

### Configuration Options Explained

- `crd_catalog`: The GitHub repository containing Custom Resource Definition (CRD) schemas.
- `resource_catalog`: The GitHub repository containing standard Kubernetes resource schemas.
- `schema_catalog_branch`: The branch name to use when fetching CRD schemas.
- `resource_catalog_branch`: The branch name to use when fetching Kubernetes resource schemas.
- `github_base_api_url`: The base URL for making GitHub API requests.
- `k8s_version`: The Kubernetes version to use for schema validation.
- `cache_dir`: Local directory where schemas are cached for faster access.
- `github_headers`: HTTP headers used when making requests to the GitHub API.

## API Functions

The plugin provides the following API functions:

```lua
-- Extract resource specification from YAML content
require('auto-k8s').extract_resource_spec(contents)

-- Find schema definition URL for a Kubernetes resource
require('auto-k8s').find_definition_url(api_version, kind)
```

## Cache

Schemas are cached in the specified `cache_dir` to improve performance and reduce GitHub API requests. The cache is automatically initialized when the plugin is set up.