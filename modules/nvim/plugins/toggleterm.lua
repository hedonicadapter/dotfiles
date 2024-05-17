require("toggleterm").setup({
        shell = "zsh",
        hide_numbers = false,
})

vim.api.nvim_exec([[
  autocmd TermOpen term://*toggleterm* startinsert | normal! A
  autocmd TermLeave term://*toggleterm* stopinsert
]], false)

  vim.api.nvim_set_keymap('n', '<C-j>', ':ToggleTerm direction=vertical size=80 <CR>', {
      noremap = true, silent = true
  })

vim.api.nvim_set_keymap('t', '<C-j>', '<cmd> :ToggleTerm<CR>', {
    noremap = true,
    silent = true
})
