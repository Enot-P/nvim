return {
  -- Дополнительная конфигурация для Flutter Tools
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = function()
      require("flutter-tools").setup({
        ui = {
          border = "rounded",
          notification_style = "nvim-notify",
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
            project_config = true,
          },
        },
        debugger = {
          enabled = true,
          exception_breakpoints = {},
          register_configurations = function()
            local dap = require("dap")
            dap.configurations.dart = {
              {
                type = "dart",
                request = "launch",
                name = "Launch flutter",
                dartSdkPath = vim.fn.expand("$HOME/develop/flutter/bin/cache/dart-sdk/"),
                flutterSdkPath = vim.fn.expand("$HOME/develop/flutter/"),
                program = "${workspaceFolder}/lib/main.dart",
                cwd = "${workspaceFolder}",
              },
            }
          end,
        },
        flutter_path = vim.fn.expand("$HOME/develop/flutter/bin/flutter"),
        flutter_lookup_cmd = nil,
        root_patterns = { ".git", "pubspec.yaml" },
        fvm_flutter_path = nil,
        widget_guides = {
          enabled = false,
        },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = ">",
          enabled = true, -- Можете отключить: enabled = false
        },
        dev_log = {
          enabled = true,
          notify_errors = false,
          open_cmd = "tabedit",
        },
        dev_tools = {
          autostart = false,
          auto_open_browser = false,
        },
        outline = {
          open_cmd = "30vnew",
          auto_open = false,
        },
        lsp = {
          color = {
            enabled = false,
            background = false,
            background_color = nil,
            foreground = false,
            virtual_text = true,
            virtual_text_str = "■",
          },
          on_attach = function(client, bufnr)
            -- Отключаем inlay hints по умолчанию при подключении LSP
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
            end
          end,
          capabilities = function(config)
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            return capabilities
          end,
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            analysisExcludedFolders = {
              vim.fn.expand("$HOME/AppData/Local/Pub/Cache"),
              vim.fn.expand("$HOME/.pub-cache"),
              vim.fn.expand("/opt/homebrew/"),
              vim.fn.expand("$HOME/develop/flutter/"),
            },
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
          },
        },
      })
    end,
    keys = {
      { "<leader>Fc", "<cmd>Telescope flutter commands<cr>", desc = "Flutter Commands" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Flutter Devices" },
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Flutter Emulators" },
      { "<leader>Fr", "<cmd>FlutterRun<cr>", desc = "Flutter Run" },
      { "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Flutter Quit" },
      { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Flutter Restart" },
      { "<leader>Fl", "<cmd>FlutterReload<cr>", desc = "Flutter Reload" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Flutter Outline" },
      { "<leader>Ft", "<cmd>FlutterDevTools<cr>", desc = "Flutter DevTools" },
      { "<leader>Fv", "<cmd>FlutterLogClear<cr>", desc = "Flutter Clear Logs" },
      { "<leader>Fp", "<cmd>FlutterPubGet<cr>", desc = "Flutter Pub Get" },
      { "<leader>Fu", "<cmd>FlutterPubUpgrade<cr>", desc = "Flutter Pub Upgrade" },

      -- Добавляем переключение inlay hints
      {
        "<leader>Fh",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local current_state = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
          vim.lsp.inlay_hint.enable(not current_state, { bufnr = bufnr })
          if not current_state then
            vim.notify("Inlay hints включены", vim.log.levels.INFO)
          else
            vim.notify("Inlay hints отключены", vim.log.levels.INFO)
          end
        end,
        desc = "Toggle Inlay Hints",
      },
    },
  },

  -- Настройка внешнего вида inlay hints
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Настройка цветов для inlay hints
      vim.api.nvim_set_hl(0, "LspInlayHint", {
        fg = "#6c7086", -- Более приглушенный цвет
        bg = "NONE",
        italic = true,
      })
    end,
  },

  -- Автокоманды для управления inlay hints
  {
    "neovim/nvim-lspconfig",
    config = function()
      local group = vim.api.nvim_create_augroup("DartInlayHints", { clear = true })

      -- Отключать inlay hints при входе в insert mode
      vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        pattern = "*.dart",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        end,
      })

      -- Включать обратно при выходе из insert mode (опционально)
      -- vim.api.nvim_create_autocmd("InsertLeave", {
      --   group = group,
      --   pattern = "*.dart",
      --   callback = function()
      --     local bufnr = vim.api.nvim_get_current_buf()
      --     vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      --   end,
      -- })
    end,
  },

  -- Добавляем дополнительные инструменты через Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "dart-debug-adapter",
      })
    end,
  },

  -- Настройка Treesitter для Dart
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "dart",
      })
    end,
  },

  -- Дополнительные сниппеты для Flutter/Dart
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "Nash0x7E2/awesome-flutter-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("data") .. "/lazy/awesome-flutter-snippets" },
      })
    end,
  },

  -- Dart/Flutter сниппеты
  {
    "Nash0x7E2/awesome-flutter-snippets",
    event = { "BufReadPre", "BufNewFile" },
    ft = { "dart" },
  },

  -- Настройка DAP для Dart debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local dap = require("dap")
      dap.adapters.dart = {
        type = "executable",
        command = "dart",
        args = { "debug_adapter" },
      }
      dap.configurations.dart = {
        {
          type = "dart",
          request = "launch",
          name = "Launch dart",
          dartSdkPath = vim.fn.expand("$HOME/develop/flutter/bin/cache/dart-sdk/"),
          flutterSdkPath = vim.fn.expand("$HOME/develop/flutter/"),
          program = "${workspaceFolder}/lib/main.dart",
          cwd = "${workspaceFolder}",
        },
        {
          type = "dart",
          request = "attach",
          name = "Connect dart",
          dartSdkPath = vim.fn.expand("$HOME/develop/flutter/bin/cache/dart-sdk/"),
          flutterSdkPath = vim.fn.expand("$HOME/develop/flutter/"),
          host = "127.0.0.1",
          port = 8181,
          timeout = 7000,
        },
      }
    end,
  },
}
