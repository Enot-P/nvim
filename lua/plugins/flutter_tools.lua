return {
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
    },
    config = function()
      require("flutter-tools").setup({
        ui = {
          border = "rounded",
          notification_style = "plugin",
        },
        decorations = {
          statusline = {
            app_version = false,
            device = true,
            project_config = false,
          }
        },
        debugger = {
          enabled = true, -- Включаем отладчик
          run_via_dap = true,
          register_configurations = function(paths)
            return {
              {
                name = "Launch Flutter (New Process)",
                type = "dart",
                request = "launch",
                program = "${workspaceFolder}/lib/main.dart",
                cwd = "${workspaceFolder}",
                args = {},
                toolArgs = {},
              }
            }
          end,
        },
        flutter_path = nil, -- Автоматическое определение пути
        flutter_lookup_cmd = nil,
        root_patterns = { ".git", "pubspec.yaml" },
        fvm = false,
        widget_guides = {
          enabled = true, -- Это важно для показа closing labels!
        },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = "//",
          enabled = true -- Включить closing tags
        },
        dev_log = {
          enabled = true,
          open_cmd = "tabedit",
        },
        dev_tools = {
          autostart = false,
          auto_open_browser = false,
        },
        outline = {
          open_cmd = "30vnew",
          auto_open = false
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
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          on_attach = require('me.utils').on_attach,
          settings = {
            dart = {
              lineLength = 80,       -- Из первого файла
              flutterOutline = true, -- Из первого файла
              closingLabels = true,  -- Из первого файла
            },
            showTodos = true,
            completeFunctionCalls = true,
            analysisExcludedFolders = {
              vim.fn.expand("$HOME/.pub-cache"),
              vim.fn.expand("$HOME/AppData/Local/Pub/Cache"),
            },
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
          }
        }
      })

      -- Дополнительные функции для работы с отладкой
      local function attach_to_running_flutter()
        -- Пытаемся автоматически найти VM Service URI из tmux окна
        local handle = io.popen("tmux capture-pane -t 1 -p | grep 'A Dart VM Service' | tail -1")
        if handle then
          local output = handle:read("*a")
          handle:close()

          local uri = output:match("http://[%d%.]+:%d+/[%w%-_]+=/")
          if uri then
            print("Найден VM Service URI: " .. uri)
            -- Подключаемся к отладчику через DAP
            require('dap').run({
              type = 'dart',
              request = 'attach',
              name = 'Attach to Running Flutter',
              vmServiceUri = uri,
            })
          else
            print("Не удалось найти VM Service URI автоматически")
            local manual_uri = vim.fn.input("Введите VM Service URI: ", "http://127.0.0.1:34499/")
            if manual_uri and manual_uri ~= "" then
              require('dap').run({
                type = 'dart',
                request = 'attach',
                name = 'Attach to Running Flutter',
                vmServiceUri = manual_uri,
              })
            end
          end
        end
      end

      local function get_flutter_vm_service_info()
        local handle = io.popen("tmux capture-pane -t 1 -p | grep -E '(A Dart VM Service|Flutter DevTools)' | tail -2")
        if handle then
          local output = handle:read("*a")
          handle:close()
          print("Flutter Debug Info:")
          print(output)

          -- Показываем также активные DAP сессии
          local dap = require('dap')
          if dap.session() then
            print("DAP Session: Active")
          else
            print("DAP Session: Not active")
          end
        else
          print("Не удалось получить информацию о Flutter процессе")
        end
      end

      -- Команды для удобной работы
      vim.api.nvim_create_user_command("FlutterAttach", attach_to_running_flutter, {
        desc = "Attach to running Flutter process"
      })

      vim.api.nvim_create_user_command("FlutterDebugInfo", get_flutter_vm_service_info, {
        desc = "Show Flutter VM Service information"
      })

      -- Keymaps для отладки
      vim.keymap.set('n', '<leader>fa', attach_to_running_flutter, { desc = 'Attach to Flutter process' })
      vim.keymap.set('n', '<leader>fd', get_flutter_vm_service_info, { desc = 'Flutter debug info' })

      -- Стандартные DAP keymaps
      vim.keymap.set('n', '<leader>db', require('dap').toggle_breakpoint, { desc = 'Toggle breakpoint' })
      vim.keymap.set('n', '<leader>dc', require('dap').continue, { desc = 'Continue' })
      vim.keymap.set('n', '<leader>dn', require('dap').step_over, { desc = 'Step over' })
      vim.keymap.set('n', '<leader>di', require('dap').step_into, { desc = 'Step into' })
      vim.keymap.set('n', '<leader>do', require('dap').step_out, { desc = 'Step out' })
      vim.keymap.set('n', '<leader>dr', require('dap').repl.open, { desc = 'Open REPL' })
    end
  },
  -- Добавляем nvim-dap для отладки
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      -- Настройка DAP адаптера для Dart
      dap.adapters.dart = {
        type = 'executable',
        command = 'dart',
        args = { 'debug_adapter' }
      }

      -- Альтернативная настройка адаптера (если первая не работает)
      dap.adapters.flutter = {
        type = 'executable',
        command = 'flutter',
        args = { 'debug_adapter' }
      }

      -- Конфигурации для запуска/подключения
      dap.configurations.dart = {
        {
          type = "dart",
          request = "launch",
          name = "Launch Flutter",
          dartSdkPath = vim.fn.system('which dart'):gsub('\n', ''):gsub('/bin/dart', ''),
          flutterSdkPath = vim.fn.system('which flutter'):gsub('\n', ''):gsub('/bin/flutter', ''),
          program = "${workspaceFolder}/lib/main.dart",
          cwd = "${workspaceFolder}",
        },
        {
          type = "dart",
          request = "attach",
          name = "Attach to process",
          vmServiceUri = function()
            return vim.fn.input('VM Service URI: ', 'http://127.0.0.1:34499/')
          end,
        }
      }

      -- Настройка dapui
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸" },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
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
        floating = {
          max_height = nil,  -- These can be integers or a float between 0 and 1.
          max_width = nil,   -- Floats will be treated as percentage of your screen.
          border = "single", -- Border style. Can be "single", "double" or "rounded"
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil, -- Can be integer or nil.
        }
      })

      -- Автоматически открываем/закрываем UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymap для UI
      vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Toggle DAP UI' })

      -- Дополнительные keymaps для управления сессией отладки
      vim.keymap.set('n', '<leader>ds', dap.terminate, { desc = 'Stop debugging session' })
      vim.keymap.set('n', '<leader>dR', dap.restart, { desc = 'Restart debugging session' })
    end
  }
}
