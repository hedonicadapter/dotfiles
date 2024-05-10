local on_attach = function(_, bufnr)

  local bufmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end

  bufmap('<leader>rn', vim.lsp.buf.rename)
  bufmap('<leader>ca', vim.lsp.buf.code_action)

  bufmap('gd', vim.lsp.buf.definition)
  bufmap('gD', vim.lsp.buf.declaration)
  bufmap('gI', vim.lsp.buf.implementation)
  bufmap('<leader>D', vim.lsp.buf.type_definition)

  bufmap('gr', require('telescope.builtin').lsp_references)
  bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols)
  bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols)

  bufmap('K', vim.lsp.buf.hover)

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, {})
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

require('neodev').setup()
require('lspconfig').lua_ls.setup {
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
    }
}

require('lspconfig').rnix.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}
require'lspconfig'.astro.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.azure_pipelines_ls.setup{
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
} 
require'lspconfig'.astro.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.bashls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.azure_pipelines_ls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.bicep.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
vim.cmd [[ autocmd BufNewFile,BufRead *.bicep set filetype=bicep ]]

require'lspconfig'.omnisharp.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.cssls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.dockerls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.gopls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.html.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.htmx.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.jsonls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.tsserver.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.lua_ls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.spectral.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.sqlls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.somesass_ls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
require'lspconfig'.tailwindcss.setup{
    on_attach = on_attach,
    capabilities = capabilities,
}
require'lspconfig'.terraformls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
}
require'lspconfig'.vimls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
}
require'lspconfig'.yamlls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
} 
            
