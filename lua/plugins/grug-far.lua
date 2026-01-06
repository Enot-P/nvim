return {
  "MagicDuck/grug-far.nvim",
  enabled = vim.fn.argv(0) ~= "leetcode.nvim", -- Не грузится в leet
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
    vim.keymap.set("n", "<leader>rf", ":GrugFar<CR>", { desc = "GrugFar: Find & Replace" })
    vim.keymap.set("x", "<leader>rf", ":<C-u>GrugFar visual<CR>", { desc = "GrugFar: с выделением" })
    -- Или поиск только внутри выделенного диапазона:
    vim.keymap.set("x", "<leader>ri", ":GrugFarWithin<CR>", { desc = "GrugFar: внутри выделения" })
  end,
}
