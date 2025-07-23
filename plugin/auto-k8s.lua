local autok8s = require("auto-k8s")

if vim.g.loaded_auto_k8s == 1 then
	return
end
vim.g.loaded_auto_k8s = 1

local buffer_to_string = function(buf)
	local content = vim.api.nvim_buf_get_lines(buf, 0, vim.api.nvim_buf_line_count(buf), false)
	return table.concat(content, "\n")
end

vim.api.nvim_create_user_command("WhatAmI", function()
	local buf = buffer_to_string(0)
	vim.print(autok8s.extract_resource_spec(buf))
end, {
	desc = "What is the resource of the current yaml",
})

vim.api.nvim_create_autocmd({ "LspAttach" }, {
	pattern = { "*.yaml", "*.yml" },
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client == nil then
			return
		end
		if client.name ~= "yamlls" then
			return
		end

		local bufnr = args.buf
		local buf = buffer_to_string(bufnr)
		local res = autok8s.extract_resource_spec(buf)
		if res == nil then
			return
		end

		local url = autok8s.find_definition_url(res.api_version, res.kind)
		if url == nil then
			return
		end

		if client.config.settings.yaml == nil then
			client.config.settings.yaml = {
				schemas = {},
			}
		end

		client.config.settings.yaml.schemas["kubernetes"] = nil -- delete blanket K8 schemas
		client.config.settings.yaml.schemas[url] = vim.api.nvim_buf_get_name(args.buf)

		client.notify("workspace/didChangeConfiguration", {
			settings = client.config.settings,
		})
	end,
})
