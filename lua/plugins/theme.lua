return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",              -- Выберите желаемый "вкус": "latte", "frappe", "macchiato", "mocha"
      transparent_background = false, -- <--- Эта опция делает фон прозрачным!
      integrations = {
        -- Здесь можно включить интеграции для других плагинов,
        -- чтобы они тоже использовали цвета Catppuccin
        cmp = true,
        gitsigns = true,
        -- nvimtree = true, -- Для nvim-tree (если используете его вместо neo-tree)
        neotree = true, -- Для neo-tree
        telescope = true,
        notify = true,
        mini = true,
        -- и т.д.
      },
      -- highlight_groups = {
      --     -- Вы можете переопределить конкретные группы подсветки здесь, если нужно
      --     -- Например, если какие-то элементы остаются непрозрачными
      --     -- Normal = { bg = "NONE" },
      --     -- NormalNC = { bg = "NONE" },
      -- },
    })

    -- Устанавливаем цветовую схему
    vim.cmd.colorscheme "catppuccin"

    -- Если вы хотите продолжать использовать `auto-dark-mode.nvim` с Catppuccin
    local auto_dark_mode = require("auto-dark-mode")
    auto_dark_mode.setup({
      update_interval = 1000,
      set_dark_mode = function()
        vim.opt.background = "dark"
        -- Устанавливаем конкретный вкус Catppuccin для темного режима (можно использовать "catppuccin-mocha")
        vim.cmd("colorscheme catppuccin")
      end,
      set_light_mode = function()
        vim.opt.background = "light"
        -- Устанавливаем конкретный вкус Catppuccin для светлого режима (можно использовать "catppuccin-latte")
        vim.cmd("colorscheme catppuccin")
      end,
    })
    auto_dark_mode.init()
  end,
  dependencies = {
    "f-person/auto-dark-mode.nvim",
  },
}
