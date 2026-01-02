return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "sidlatau/neotest-dart", -- Адаптер для Dart/Flutter тестов
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-dart")({
          command = "flutter", -- Используем команду flutter test вместо dart test
          use_lsp = true, -- Используем LSP (Dart Analysis Server) для более точного обнаружения тестов
        }),
      },
      -- Настройки отображения статуса тестов
      status = { virtual_text = true }, -- Показывать статус тестов прямо в коде (passed/failed и т.д.)
      output = { open_on_run = true }, -- Автоматически открывать панель вывода при запуске тестов
    })

    local neotest = require("neotest")

    -- Запуск ближайшего теста (под курсором)
    vim.keymap.set("n", "<leader>ftr", function()
      neotest.run.run()
    end, { desc = "Flutter Test: Запустить ближайший тест" })

    -- Запуск всех тестов в текущем файле
    vim.keymap.set("n", "<leader>ftf", function()
      neotest.run.run(vim.fn.expand("%"))
    end, { desc = "Flutter Test: Запустить тесты в текущем файле" })

    -- Открыть/закрыть панель summary (дерево тестов)
    vim.keymap.set("n", "<leader>fts", function()
      neotest.summary.toggle()
    end, { desc = "Flutter Test: Переключить панель обзора тестов" })

    -- Запуск ближайшего теста в режиме отладки через DAP
    vim.keymap.set("n", "<leader>ftd", function()
      neotest.run.run({ strategy = "dap" })
    end, { desc = "Flutter Test: Отладить ближайший тест (DAP)" })
    -- Запуск всех тестов в проекте
    vim.keymap.set("n", "<leader>fta", function()
      neotest.run.run({ vim.loop.cwd() })
    end, { desc = "Flutter Test: Запустить все тесты в проекте" })

    -- Повторить последний запуск
    vim.keymap.set("n", "<leader>ftl", function()
      neotest.run.run_last()
    end, { desc = "Flutter Test: Повторить последний запуск" })

    -- Остановить текущий запуск
    vim.keymap.set("n", "<leader>ftx", function()
      neotest.run.stop()
    end, { desc = "Flutter Test: Остановить тесты" })

    -- Открыть панель вывода (если не открывается автоматически)
    vim.keymap.set("n", "<leader>fto", function()
      neotest.output.open({ enter = true })
    end, { desc = "Flutter Test: Открыть панель вывода" })

    -- Открыть вывод конкретного теста в плавающем окне
    vim.keymap.set("n", "<leader>ftp", function()
      neotest.output_panel.toggle()
    end, { desc = "Flutter Test: Переключить панель полного вывода" })
  end,
}
