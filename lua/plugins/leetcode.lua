return {
  "kawre/leetcode.nvim",
  lazy = "leetcode.nvim" ~= vim.fn.argv(0), -- Загрузится с аргументом
  build = ":TSUpdate html",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    arg = "leetcode.nvim", -- С этим аргументом
    lang = "dart",

    picker = {
      provider = "snacks-picker",
    },
  },
}
