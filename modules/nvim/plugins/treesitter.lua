        require('nvim-treesitter.install').compilers = { "gcc" }
        require('nvim-treesitter.configs').setup {
            highlight = {
                enable = true
            },
            autotag = {
                enable = true
            },
            indent = {
                enable = true
            },
            incremental_selection = {
                enable = true
            },

        }
