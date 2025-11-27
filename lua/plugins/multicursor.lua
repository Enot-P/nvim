return {
  "brenton-leighton/multiple-cursors.nvim",
  version = "*",
  opts = {},
  keys = {
    { "<leader>mj", "<Cmd>MultipleCursorsAddDown<CR>", mode = { "n", "x" }, desc = "Мультикурсор: добавить вниз" },
    { "<leader>mk", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "x" }, desc = "Мультикурсор: добавить вверх" },
    { "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = { "n", "i" }, desc = "Мультикурсор: мышью добавить/удалить" },
    { "<leader>mv", "<Cmd>MultipleCursorsAddVisualArea<CR>", mode = { "x" }, desc = "Мультикурсор: по визуальной области" },
    { "<leader>ma", "<Cmd>MultipleCursorsAddMatches<CR>", mode = { "n", "x" }, desc = "Мультикурсор: по совпадениям слова" },
    { "<leader>mn", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = { "n", "x" }, desc = "Мультикурсор: следующее совпадение" },
    { "<leader>ml", "<Cmd>MultipleCursorsLock<CR>", mode = { "n", "x" }, desc = "Мультикурсор: заблокировать" },
  },
}


