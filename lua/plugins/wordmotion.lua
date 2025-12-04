return {
  "chaoren/vim-wordmotion",
  event = "VeryLazy",
  init = function()
    vim.g.wordmotion_nomap = 1
  end,
  config = function()
    local modes = { "n", "x", "o" }
    local opts = { silent = true, remap = true }

    vim.keymap.set(modes, "w", "<Plug>WordMotion_w", vim.tbl_extend("force", opts, { desc = "Следующая часть слова" }))
    vim.keymap.set(modes, "e", "<Plug>WordMotion_e", vim.tbl_extend("force", opts, { desc = "Конец части слова" }))
    vim.keymap.set(modes, "b", "<Plug>WordMotion_b", vim.tbl_extend("force", opts, { desc = "Предыдущая часть слова" }))
    vim.keymap.set(modes, "ge", "<Plug>WordMotion_ge", vim.tbl_extend("force", opts, { desc = "Конец предыдущей части" }))
  end,
}
