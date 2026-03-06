return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "sidlatau/neotest-dart", -- Адаптер для Dart/Flutter тестов
    "nvim-neotest/neotest-go", -- Адаптер для Go тестов
  },
  enabled = vim.fn.argv(0) ~= "leetcode.nvim", -- Не грузится в leet
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-dart")({
          command = "flutter", -- Используем команду flutter test вместо dart test
          use_lsp = true, -- Используем LSP (Dart Analysis Server) для более точного обнаружения тестов
        }),
        require("neotest-go")({
          experimental = {
            test_table = true,
          },
        }),
      },
      -- Настройки отображения статуса тестов
      status = { virtual_text = true }, -- Показывать статус тестов прямо в коде (passed/failed и т.д.)
      output = { open_on_run = true }, -- Автоматически открывать панель вывода при запуске тестов
    })

    local neotest = require("neotest")

    -- Flutter: запуск ближайшего теста (под курсором)
    vim.keymap.set("n", "<leader>ftr", function()
      neotest.run.run()
    end, { desc = "Flutter Test: Запустить ближайший тест" })

    -- Flutter: запуск всех тестов в текущем файле
    vim.keymap.set("n", "<leader>ftf", function()
      neotest.run.run(vim.fn.expand("%"))
    end, { desc = "Flutter Test: Запустить тесты в текущем файле" })

    -- Flutter: открыть/закрыть панель summary (дерево тестов)
    vim.keymap.set("n", "<leader>fts", function()
      neotest.summary.toggle()
    end, { desc = "Flutter Test: Переключить панель обзора тестов" })

    -- Flutter: запуск ближайшего теста в режиме отладки через DAP
    vim.keymap.set("n", "<leader>ftd", function()
      neotest.run.run({ strategy = "dap" })
    end, { desc = "Flutter Test: Отладить ближайший тест (DAP)" })
    -- Flutter: запуск всех тестов в проекте
    vim.keymap.set("n", "<leader>fta", function()
      neotest.run.run({ vim.loop.cwd() })
    end, { desc = "Flutter Test: Запустить все тесты в проекте" })

    -- Flutter: повторить последний запуск
    vim.keymap.set("n", "<leader>ftl", function()
      neotest.run.run_last()
    end, { desc = "Flutter Test: Повторить последний запуск" })

    -- Flutter: остановить текущий запуск
    vim.keymap.set("n", "<leader>ftx", function()
      neotest.run.stop()
    end, { desc = "Flutter Test: Остановить тесты" })

    -- Flutter: открыть панель вывода (если не открывается автоматически)
    vim.keymap.set("n", "<leader>fto", function()
      neotest.output.open({ enter = true })
    end, { desc = "Flutter Test: Открыть панель вывода" })

    -- Flutter: открыть вывод конкретного теста в плавающем окне
    vim.keymap.set("n", "<leader>ftp", function()
      neotest.output_panel.toggle()
    end, { desc = "Flutter Test: Переключить панель полного вывода" })

    -- Go тесты
    vim.keymap.set("n", "<leader>gtr", function()
      neotest.run.run()
    end, { desc = "Go Test: запустить ближайший тест" })

    vim.keymap.set("n", "<leader>gtf", function()
      neotest.run.run(vim.fn.expand("%"))
    end, { desc = "Go Test: запустить тесты в файле" })

    vim.keymap.set("n", "<leader>gts", function()
      neotest.summary.toggle()
    end, { desc = "Go Test: переключить панель обзора тестов" })

    vim.keymap.set("n", "<leader>gtd", function()
      neotest.run.run({ strategy = "dap" })
    end, { desc = "Go Test: отладить ближайший тест (DAP)" })

    vim.keymap.set("n", "<leader>gta", function()
      neotest.run.run({ vim.loop.cwd() })
    end, { desc = "Go Test: запустить все тесты в проекте" })

    vim.keymap.set("n", "<leader>gtl", function()
      neotest.run.run_last()
    end, { desc = "Go Test: повторить последний запуск" })

    vim.keymap.set("n", "<leader>gtx", function()
      neotest.run.stop()
    end, { desc = "Go Test: остановить тесты" })

    vim.keymap.set("n", "<leader>gto", function()
      neotest.output.open({ enter = true })
    end, { desc = "Go Test: открыть панель вывода" })

    vim.keymap.set("n", "<leader>gtp", function()
      neotest.output_panel.toggle()
    end, { desc = "Go Test: переключить панель полного вывода" })
  end,
}
