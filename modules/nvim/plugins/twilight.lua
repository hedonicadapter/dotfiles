require('twilight').setup {
        dimming = {
            alpha = 0.75
        },
        treesitter = true
}

vim.api.nvim_exec([[
    au BufEnter * TwilightEnable
]], false)
