require("copilot").setup({
            suggestion = {
                auto_trigger = true,
                keymap = {
                    accept = "<Tab>"
                }
            }
        })

        vim.api.nvim_exec([[
          au VimEnter * Copilot auth
        ]], false)