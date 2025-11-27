return {
  {
    "kylechui/nvim-surround",
    version = "*",      -- Используем последнюю версию
    event = "VeryLazy", -- Загружаем плагин после старта Neovim
    config = function()
      require("nvim-surround").setup({
        -- Настройки (пример):
        keymaps = { -- Можно настроить свои сочетания клавиш
          normal = "<leader>ys",
          visual = "<leader>s",
          delete = "<leader>ds",
          change = "<leader>cs",
        },
      })
    end,
  },
}
