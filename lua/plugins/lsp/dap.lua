return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      -- Базовая конфигурация DAP
      -- Адаптер для Dart будет настроен автоматически flutter-tools

      -- Визуальное выделение текущей строки выполнения
      -- Настройка highlight для строки, на которой остановился дебаггер
      vim.fn.sign_define("DapBreakpoint", {
        text = "🔴",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "🟡",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "⚫",
        texthl = "DapBreakpointRejected",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "📝",
        texthl = "DapLogPoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "→",
        texthl = "DapStopped",
        linehl = "DapStoppedLine", -- выделение всей строки
        numhl = "DapStoppedLine",
      })

      -- Настройка цветов для выделения
      vim.api.nvim_set_hl(0, "DapStoppedLine", {
        bg = "#3e1e6e",
        bold = true,
      })
      vim.api.nvim_set_hl(0, "DapBreakpoint", {
        fg = "#993939",
      })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", {
        fg = "#d4a373",
      })
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", {
        fg = "#808080",
      })
      vim.api.nvim_set_hl(0, "DapLogPoint", {
        fg = "#61afef",
      })

      -- Хоткеи для Debugger
      vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F1>", function() dap.step_into() end, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F2>", function() dap.step_over() end, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F3>", function() dap.step_out() end, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>do", function() dap.step_over() end, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<leader>dO", function() dap.step_out() end, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "Debug: Toggle REPL" })
      vim.keymap.set("n", "<leader>dl", function() dap.run_last() end, { desc = "Debug: Run Last" })
      vim.keymap.set("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Debug: Toggle UI" })
      vim.keymap.set("n", "<leader>dx", function() dap.terminate() end, { desc = "Debug: Terminate" })
      vim.keymap.set("n", "<leader>dC", function() dap.clear_breakpoints() end, { desc = "Debug: Clear Breakpoints" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio", -- обязательная зависимость для nvim-dap-ui
    },
    config = function()
      local dapui = require("dapui")
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        -- Use this to override mappings for specific elements
        element_mappings = {},
        -- Expand lines larger than the window
        -- Requires >= 0.7
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        -- Layouts define sections of the screen to place windows.
        -- The position can be "left", "right", "top" or "bottom".
        -- The size specifies the height/width depending on position. It can be an Int
        -- or a Float. Integer specifies "rows" while Float specifies percentage.
        -- Elements are the elements shown in the layout (in order).
        -- Layouts are opened in order so that earlier layouts take priority in window sizing.
        layouts = {
          {
            elements = {
              -- Elements can be strings or table with id and size keys.
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40, -- 40 columns
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
          },
        },
        controls = {
          -- Requires Neovim nightly (or 0.8 when released)
          enabled = true,
          -- Display controls in this element
          element = "repl",
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏬",
            step_over = "⏭",
            step_out = "⏫",
            step_back = "⏮",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏸",
          },
        },
        floating = {
          max_height = nil, -- These can be integers or a float between 0 and 1.
          max_width = nil, -- Floats will be treated as percentage of your screen.
          border = "single", -- Border style. Can be "single", "double" or "rounded"
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil, -- Can be integer or nil.
          max_value_lines = 100, -- Can be integer or nil.
        },
      })

      -- Автоматически открывать/закрывать DAP UI при старте/остановке отладки
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-treesitter/nvim-treesitter", -- для лучшей работы с виртуальным текстом
    },
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        -- Показывать виртуальный текст для всех буферов, а не только для текущего
        enabled_commands = true,
        -- Подсветка измененных значений
        highlight_changed_variables = true,
        -- Подсветка новых переменных
        highlight_new_as_changed = false,
        -- Показывать виртуальный текст для остановок
        show_stop_reason = true,
        -- Комментировать виртуальный текст
        commented = false,
        -- Только для определенных типов файлов (nil = все)
        only_first_definition = true,
        -- Все определения
        all_references = false,
        -- Фильтр для очистки виртуального текста
        clear_on_continue = false,
        -- Отступ для виртуального текста
        virt_text_pos = "eol", -- eol, overlay, right_align
        -- Максимальная длина виртуального текста
        all_frames = false,
        -- Виртуальный текст для всех фреймов
        virt_lines = false,
        -- Виртуальные линии
        virt_text_win_col = nil,
      })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      -- Автоматическая установка адаптеров через Mason
      ensure_installed = {
        -- dart-debug-adapter уже установлен через mason-tool-installer
      },
      automatic_installation = true,
    },
  },
}
