return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  ft = "dart",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/conform.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local flutter_session = vim.fn.getenv("TMUX") and vim.fn.system("tmux display-message -p '#S'"):gsub("\n", "") or "flutter_dev"
    local flutter_window = "flutter_run"

    -- Функция для создания окна в текущей Tmux-сессии
    local function create_flutter_tmux_window()
      local cwd = vim.fn.getcwd()
      local window_exists = vim.fn.system("tmux list-windows -t " .. flutter_session .. " | grep " .. flutter_window)
      if window_exists == "" then
        vim.fn.system("tmux new-window -t " .. flutter_session .. " -n " .. flutter_window .. " -c " .. cwd)
      end
    end

    -- Функция для запуска Flutter в Tmux
    local function flutter_run_tmux()
      if not vim.fn.getenv("TMUX") then
        vim.notify("Not inside a Tmux session", vim.log.levels.ERROR)
        return
      end
      create_flutter_tmux_window()
      vim.fn.system("tmux send-keys -t " .. flutter_session .. ":" .. flutter_window .. " 'flutter run' Enter")
      vim.fn.system("tmux select-window -t " .. flutter_session .. ":" .. flutter_window)
    end

    -- Функция для отправки команд в Tmux
    local function send_flutter_command(command)
      local cmd = "tmux send-keys -t " .. flutter_session .. ":" .. flutter_window .. " '" .. command .. "' Enter"
      local status = vim.fn.system(cmd)
      if status ~= "" then
        vim.notify("Failed to send command to Tmux", vim.log.levels.ERROR)
      end
    end

    -- Создаем пользовательские команды
    vim.api.nvim_create_user_command('FlutterRunTmux', flutter_run_tmux, {})
    vim.api.nvim_create_user_command('FlutterReloadTmux', function()
      send_flutter_command("r")
    end, {})
    vim.api.nvim_create_user_command('FlutterRestartTmux', function()
      send_flutter_command("R")
    end, {})
    vim.api.nvim_create_user_command('FlutterQuitTmux', function()
      send_flutter_command("q")
      vim.fn.system("tmux kill-window -t " .. flutter_session .. ":" .. flutter_window)
    end, {})

    -- Автокоманда для горячей перезагрузки при сохранении Dart-файла
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.dart",
      callback = function()
        if vim.fn.getenv("TMUX") then
          local window_exists = vim.fn.system("tmux list-windows -t " .. flutter_session .. " | grep " .. flutter_window)
          if window_exists ~= "" then
            send_flutter_command("r")
          end
        end
      end,
      desc = "Trigger Flutter hot reload on Dart file save",
    })

    require("flutter-tools").setup {
      dev_log = {
        enabled = false,
      },
      ui = {
        border = "rounded",
        notification_style = 'native',
      },
      lsp = {
        color = {
          enabled = true,
          background = false,
          foreground = false,
          virtual_text = true,
          virtual_text_str = "■",
        },
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          enableSnippets = true,
          updateImportsOnRename = true,
        },
      },
    }

    -- Биндинги клавиш
    vim.keymap.set('n', '<leader>fr', ':FlutterRunTmux<CR>', { desc = 'Flutter Run in Tmux' })
    vim.keymap.set('n', '<leader>frl', ':FlutterReloadTmux<CR>', { desc = 'Flutter Reload' })
    vim.keymap.set('n', '<leader>frs', ':FlutterRestartTmux<CR>', { desc = 'Flutter Restart' })
    vim.keymap.set('n', '<leader>fq', ':FlutterQuitTmux<CR>', { desc = 'Flutter Quit' })
    vim.keymap.set('n', '<leader>fd', ':FlutterDevices<CR>', { desc = 'Flutter Devices' })
    vim.keymap.set('n', '<leader>fe', ':FlutterEmulators<CR>', { desc = 'Flutter Emulators' })
  end,
}
