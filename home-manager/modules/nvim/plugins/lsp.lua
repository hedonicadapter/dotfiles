-- local navbuddy = require("nvim-navbuddy")

local on_attach = function(client, bufnr)
	vim.g.inlay_hints_visible = true
	vim.lsp.inlay_hint.enable(true)
	-- navbuddy.attach(client, bufnr)

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

local lspconfig = require("lspconfig")
local coq = require("coq")

vim.diagnostic.config(
	{
		underline = true,
		update_in_insert = false,
		virtual_text = {
			spacing = 4,
			source = "if_many",
			prefix = "●",
		},
		severity_sort = true,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = ,
				[vim.diagnostic.severity.WARN] = ,
				[vim.diagnostic.severity.HINT] = 󰧑,
				[vim.diagnostic.severity.INFO] = ,
			},
		},
		inlay_hints = {
			enabled = true,
		},
	}
)

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

lspconfig.nil_ls.setup(coq.lsp_ensure_capabilities({
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

-- lspconfig.omnisharp.setup(coq.lsp_ensure_capabilities({
-- 		on_attach = on_attach,
-- 		capabilities = capabilities,
-- 	    cmd = { "dotnet", "OmniSharp" },
-- 	filetypes = {"cs", "cshtml", "razor", "csproj", },
-- handlers = {
--     ["textDocument/definition"] = require('omnisharp_extended').definition_handler,
--     ["textDocument/typeDefinition"] = require('omnisharp_extended').type_definition_handler,
--     ["textDocument/references"] = require('omnisharp_extended').references_handler,
--     ["textDocument/implementation"] = require('omnisharp_extended').implementation_handler,
--   },
--         keys = {
--           {
--             "gd",
--             function()
--               require("omnisharp_extended").telescope_lsp_definitions()
--             end,
--             desc = "Goto Definition",
--           },
--         },
-- 	    settings = {
-- 	      FormattingOptions = {
-- 		EnableEditorConfigSupport = true,
-- 	      },
-- 	      MsBuild = {
-- 		-- If true, MSBuild project system will only load projects for files that
-- 		-- were opened in the editor. This setting is useful for big C# codebases
-- 		-- and allows for faster initialization of code navigation features only
-- 		-- for projects that are relevant to code that is being edited. With this
-- 		-- setting enabled OmniSharp may load fewer projects and may thus display
-- 		-- incomplete reference lists for symbols.
-- 		LoadProjectsOnDemand = nil,
-- 	      },
-- 	      RoslynExtensionsOptions = {
-- 		-- Enables support for roslyn analyzers, code fixes and rulesets.
-- 		EnableAnalyzersSupport = true,
-- 		-- Enables support for showing unimported types and unimported extension
-- 		-- methods in completion lists. When committed, the appropriate using
-- 		-- directive will be added at the top of the current file. This option can
-- 		-- have a negative impact on initial completion responsiveness,
-- 		-- particularly for the first few completion sessions after opening a
-- 		-- solution.
-- 		EnableImportCompletion = true,
-- 		-- Only run analyzers against open files when 'enableRoslynAnalyzers' is
-- 		-- true
-- 		AnalyzeOpenDocumentsOnly = nil,
-- 	      },
-- 	      Sdk = {
-- 		IncludePrereleases = true,
-- 	      },
-- 	    },
-- 	}))
require("roslyn").setup({
    dotnet_cmd = "dotnet", -- this is the default
    roslyn_version = "4.8.0-3.23475.7", -- this is the default
    on_attach = on_attach,
    capabilities = capabilities,
})
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
  capabilities = capabilities,
  single_file_support = true,
  root_dir = require('lspconfig.util').root_pattern('.git'),
  completions = {
    completeFunctionCalls = true,
  },
  settings = {
    javascript = {
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = false,
      },
    },

    typescript = {
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = false,
      },
    },
  },
}))
lspconfig.lua_ls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,

	on_init = function(client)
	    local path = client.workspace_folders[1].name
	    if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
	      return
	    end

	    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
	      runtime = {
		-- Tell the language server which version of Lua you're using
		-- (most likely LuaJIT in the case of Neovim)
		version = 'LuaJIT'
	      },
	      -- Make the server aware of Neovim runtime files
	      workspace = {
		checkThirdParty = false,
		library = {
		  vim.env.VIMRUNTIME
		  -- Depending on the usage, you might want to add additional paths here.
		  -- "${3rd}/luv/library"
		  -- "${3rd}/busted/library",
		}
		-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
		-- library = vim.api.nvim_get_runtime_file("", true)
	      }
	    })
	end,
	settings = {
		Lua = {}
	}
}))
lspconfig.sqls.setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	capabilities = capabilities,
}))
lspconfig.tailwindcss.setup(coq.lsp_ensure_capabilities({
  capabilities = capabilities,
  completions = {
    completeFunctionCalls = true,
  },
  root_dir = lspconfig.util.root_pattern(
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.cjs",
    "postcss.config.ts"
  ),
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


