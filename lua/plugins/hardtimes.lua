return {
  "m4xshen/hardtime.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim", "folke/snacks.nvim" }, -- snacks для notifier
  opts = {
    max_count = 3,
    max_time = 1000,

    -- Красивые уведомления через snacks.notifier (в правом верхнем углу)
    notification = true,
    callback = function(msg)
      Snacks.notifier.notify(msg, vim.log.levels.WARN, {
        title = "hardtime.nvim",
      })
    end,
    -- Подсказки тоже через notifier (hint = true по умолчанию)
    hint = true,

    disabled_keys = {
      ["<Up>"] = { "i" },
      ["<Down>"] = { "i" },
      ["<Left>"] = { "i" },
      ["<Right>"] = { "i" },
    },

    -- Отключаем в типичных UI-окнах, где hardtime только мешает
    disabled_filetypes = {
      "TelescopePrompt",
      "lazy",
      "mason",
      "dapui*",
      "noice",
      "notify",
      "oil",
      "qf",
      "fugitive",
      "git",
      "snacks_picker", -- пикеры snacks
      "snacks_terminal", -- терминал snacks
      "snacks_explorer", -- explorer snacks
    },

    -- Принудительный выход из insert при бездействии (чтобы не залипать)
    -- force_exit_insert_mode = true,
    -- max_insert_idle_ms = 5000, -- 5 секунд
  },
}
