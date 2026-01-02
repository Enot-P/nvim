return {
  "MagicDuck/grug-far.nvim",
  event = "VeryLazy", -- или cmd = "GrugFar", если хотите ленивее
  config = function()
    require("grug-far").setup({
      startInInsertMode = false, -- начинать в normal mode
      transient = true, -- буфер исчезает при закрытии окна
      keymaps = {
        close = "<localleader>c",
        replace = "<localleader>r",
        -- и т.д.
      },
    })
    vim.keymap.set("n", "<leader>fr", ":GrugFar<CR>", { desc = "GrugFar: Find & Replace" })
    vim.keymap.set("x", "<leader>fr", ":<C-u>GrugFar visual<CR>", { desc = "GrugFar: с выделением" })
    -- Или поиск только внутри выделенного диапазона:
    vim.keymap.set("x", "<leader>fi", ":GrugFarWithin<CR>", { desc = "GrugFar: внутри выделения" })
  end,
}
