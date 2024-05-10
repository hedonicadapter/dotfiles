local on_attach = function(_, bufnr)
	local bufmap = function(keys, func)
		vim.keymap.set("n", keys, func, { buffer = bufnr })
	end

	bufmap("<leader>rn", vim.lsp.buf.rename)
	bufmap("<leader>ca", vim.lsp.buf.code_action)

	bufmap("gd", vim.lsp.buf.definition)
	bufmap("gD", vim.lsp.buf.declaration)
	bufmap("gI", vim.lsp.buf.implementation)
	bufmap("<leader>D", vim.lsp.buf.type_definition)

	bufmap("gr", require("telescope.builtin").lsp_references)
	bufmap("<leader>s", require("telescope.builtin").lsp_document_symbols)
	bufmap("<leader>S", require("telescope.builtin").lsp_dynamic_workspace_symbols)

	bufmap("K", vim.lsp.buf.hover)

	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, {})
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

require("neodev").setup()
local lspconfig = require("lspconfig")
local coq = require("coq")

lspconfig.lua_ls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = function()
		return vim.loop.cwd()
	end,
	cmd = { "lua-lsp" },
	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}))

lspconfig.rnix.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.astro.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.azure_pipelines_ls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,

	settings = {
		yaml = {
			schemas = {
				["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
					"/azure-pipeline*.y*l",
					"/*.azure*",
					"Azure-Pipelines/**/*.y*l",
					"Pipelines/*.y*l",
				},
			},
		},
	},
}))
lspconfig.astro.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.bashls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.azure_pipelines_ls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.bicep.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
vim.cmd([[ autocmd BufNewFile,BufRead *.bicep set filetype=bicep ]])

lspconfig.omnisharp.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.cssls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.dockerls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.gopls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.html.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.htmx.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.jsonls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.lua_ls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.spectral.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.sqlls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.somesass_ls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.tailwindcss.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.terraformls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.vimls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.yamlls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
