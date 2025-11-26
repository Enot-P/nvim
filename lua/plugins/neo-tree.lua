return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      -- Изменяем позицию по умолчанию на правую
      opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
        position = "right",
      })
    end,
  },
}
