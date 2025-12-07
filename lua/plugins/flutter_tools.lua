return {
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
    },
    config = function()
      -- Проверяем наличие utils модуля
      local utils_ok, utils = pcall(require, 'me.utils')
      local on_attach_fn = utils_ok and utils.on_attach or function() end

      -- Проверяем наличие cmp
      local cmp_ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
      local capabilities = cmp_ok and cmp_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

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
          enabled = true,
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
        flutter_path = nil,
        flutter_lookup_cmd = nil,
        root_patterns = { ".git", "pubspec.yaml" },
        fvm = false,
        widget_guides = {
          enabled = true,
        },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = "//",
          enabled = true
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
            enabled = true,
            background = true,
            background_color = nil,
            foreground = true,
            virtual_text = true,
            virtual_text_str = "■ ",
          },
          capabilities = capabilities,
          on_attach = on_attach_fn,
          settings = {
            dart = {
              lineLength = 80,
              flutterOutline = true,
              closingLabels = true,
              analysisExcludedFolders = {
                vim.fn.expand("$HOME/.pub-cache"),
                vim.fn.expand("$HOME/AppData/Local/Pub/Cache"),
                vim.fn.expand("$HOME/fvm"),
              },
              enableSdkFormatter = true,
              enableServerSnippets = true,
              includeDependenciesInWorkspaceSymbols = false,
              completeFunctionCalls = true,
              showTodos = true,
              renameFilesWithClasses = "prompt",
              enableSnippets = true,
              updateImportsOnRename = true,
            }
          }
        },
      })

      -- Улучшенная функция поиска Flutter VM Services во всех tmux окнах
      local function find_flutter_vm_uris()
        local uris = {}

        -- Ищем во всех tmux окнах
        local windows_handle = io.popen("tmux list-windows -F '#{window_index}' 2>/dev/null")
        if windows_handle then
          local windows = windows_handle:read("*a")
          windows_handle:close()

          for window in windows:gmatch("[^\r\n]+") do
            local capture_handle = io.popen(string.format(
              "tmux capture-pane -t %s -p 2>/dev/null | grep 'A Dart VM Service'", window))
            if capture_handle then
              local output = capture_handle:read("*a")
              capture_handle:close()

              if output and output ~= "" then
                for line in output:gmatch("[^\r\n]+") do
                  local uri = line:match("(http://[%d%.]+:%d+/[%w%-_]+=/)")
                  if uri then
                    table.insert(uris, {
                      uri = uri,
                      window = window,
                      line = line
                    })
                  end
                end
              end
            end
          end
        end

        return uris
      end

      -- Telescope интеграция для выбора VM Service
      local function attach_with_telescope()
        local uris = find_flutter_vm_uris()

        if #uris == 0 then
          print("No Flutter VM Service found")
          return
        end

        if #uris == 1 then
          local uri = uris[1].uri
          print("Auto-connecting to: " .. uri .. " (window " .. uris[1].window .. ")")
          require('dap').run({
            type = 'dart',
            request = 'attach',
            name = 'Attach to Flutter',
            vmServiceUri = uri,
          })
          return
        end

        -- Проверяем наличие telescope
        local has_telescope, telescope = pcall(require, 'telescope')
        if not has_telescope then
          print("Telescope not available, falling back to manual selection")
          print("Found multiple Flutter VM Services:")
          for i, uri_info in ipairs(uris) do
            print(string.format("[%d] Window %s: %s", i, uri_info.window, uri_info.uri))
          end

          local choice = tonumber(vim.fn.input("Select VM Service (1-" .. #uris .. "): "))
          if choice and choice >= 1 and choice <= #uris then
            local selected_uri = uris[choice].uri
            print("Connecting to: " .. selected_uri)
            require('dap').run({
              type = 'dart',
              request = 'attach',
              name = 'Attach to Flutter',
              vmServiceUri = selected_uri,
            })
          end
          return
        end

        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        local opts = {}

        pickers.new(opts, {
          prompt_title = "Flutter VM Services",
          finder = finders.new_table {
            results = uris,
            entry_maker = function(entry)
              return {
                value = entry.uri,
                display = string.format("Window %s: %s", entry.window, entry.uri),
                ordinal = entry.uri,
              }
            end,
          },
          sorter = conf.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                print("Connecting to: " .. selection.value)
                require('dap').run({
                  type = 'dart',
                  request = 'attach',
                  name = 'Attach to Flutter (Telescope)',
                  vmServiceUri = selection.value,
                })
              end
            end)
            return true
          end,
        }):find()
      end

      -- Умная функция подключения к Flutter процессу
      local function attach_to_running_flutter()
        local uris = find_flutter_vm_uris()

        if #uris == 0 then
          print("No Flutter VM Service found in tmux windows")
          local manual_uri = vim.fn.input("Enter VM Service URI manually: ", "http://127.0.0.1:40499/")
          if manual_uri and manual_uri ~= "" then
            require('dap').run({
              type = 'dart',
              request = 'attach',
              name = 'Manual Attach to Flutter',
              vmServiceUri = manual_uri,
            })
          end
          return
        end

        if #uris == 1 then
          -- Один URI найден - подключаемся автоматически
          local uri = uris[1].uri
          print("Auto-connecting to: " .. uri .. " (window " .. uris[1].window .. ")")
          require('dap').run({
            type = 'dart',
            request = 'attach',
            name = 'Attach to Flutter',
            vmServiceUri = uri,
          })
        else
          -- Несколько URI - используем Telescope если доступен
          local has_telescope = pcall(require, 'telescope')
          if has_telescope then
            attach_with_telescope()
          else
            -- Показываем простой выбор
            print("Multiple Flutter VM Services found:")
            for i, uri_info in ipairs(uris) do
              print(string.format("[%d] Window %s: %s", i, uri_info.window, uri_info.uri))
            end

            local choice = tonumber(vim.fn.input("Select VM Service (1-" .. #uris .. "): "))
            if choice and choice >= 1 and choice <= #uris then
              local selected_uri = uris[choice].uri
              print("Connecting to: " .. selected_uri)
              require('dap').run({
                type = 'dart',
                request = 'attach',
                name = 'Attach to Flutter',
                vmServiceUri = selected_uri,
              })
            else
              print("Invalid selection")
            end
          end
        end
      end

      local function get_flutter_vm_service_info()
        local uris = find_flutter_vm_uris()

        print("=== Flutter Debug Information ===")

        if #uris == 0 then
          print("No Flutter VM Services found in tmux windows")
          print("Make sure flutter run is started in one of the tmux windows")
        else
          print("Found Flutter VM Services:")
          for i, uri_info in ipairs(uris) do
            print(string.format("  [%d] Window %s: %s", i, uri_info.window, uri_info.uri))
          end
        end

        -- Показываем также активные DAP сессии
        local dap_ok, dap = pcall(require, 'dap')
        if dap_ok and dap.session() then
          print("\nDAP Session: Active")
          print("Session ID: " .. tostring(dap.session().id))
        else
          print("\nDAP Session: Not active")
        end
      end

      -- Команды для удобной работы
      vim.api.nvim_create_user_command("FlutterAttach", attach_to_running_flutter, {
        desc = "Smart attach to running Flutter process"
      })

      vim.api.nvim_create_user_command("FlutterAttachTelescope", attach_with_telescope, {
        desc = "Attach to Flutter using Telescope"
      })

      vim.api.nvim_create_user_command("FlutterDebugInfo", get_flutter_vm_service_info, {
        desc = "Show Flutter VM Service information"
      })

      vim.api.nvim_create_user_command("FlutterFindServices", function()
        local uris = find_flutter_vm_uris()
        if #uris == 0 then
          print("No Flutter VM Services found")
        else
          print("Found Flutter VM Services:")
          for i, uri_info in ipairs(uris) do
            print(string.format("  [%d] Window %s: %s", i, uri_info.window, uri_info.uri))
          end
        end
      end, {
        desc = "Find all Flutter VM Services in tmux windows"
      })

      -- Keymaps для отладки
      vim.keymap.set('n', '<leader>fa', attach_to_running_flutter, { desc = 'Smart attach to Flutter' })

      -- Стандартные DAP keymaps - только если dap доступен
      local dap_ok, dap = pcall(require, 'dap')
      if dap_ok then
        vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
        vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue' })
        vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Step over' })
        vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step into' })
        vim.keymap.set('n', '<leader>dd', dap.step_out, { desc = 'Step out' })
        vim.keymap.set('n', '<F10>', dap.repl.open, { desc = 'Open REPL' })
      end
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
            return vim.fn.input('VM Service URI: ', 'http://127.0.0.1:40499/')
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
              "stacks",
              "breakpoints",
              "watches",
              { id = "scopes", size = 0.25 },
            },
            size = 60, -- 40 columns
            position = "left",
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
  },
  --- For pubspec
  {
    'akinsho/pubspec-assist.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('pubspec-assist').setup()
    end,
  }
}
