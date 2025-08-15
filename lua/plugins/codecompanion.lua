-- ~/.config/nvim/lua/plugins/codecompanion.lua
-- Конфигурация для codecompanion.nvim и copilot

return {
  -- GitHub Copilot
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Основные настройки Copilot
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true

      -- Горячие клавиши для Copilot
      vim.keymap.set('i', '<C-g>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false
      })
      vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)')
      vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)')
      vim.keymap.set('i', '<C-o>', '<Plug>(copilot-dismiss)')
      vim.keymap.set('i', '<C-s>', '<Plug>(copilot-suggest)')
    end,
  },

  -- CodeCompanion.nvim
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",              -- Опционально для автодополнения
      "nvim-telescope/telescope.nvim", -- Опционально для поиска
      {
        "stevearc/dressing.nvim",      -- Опционально для лучшего UI
        opts = {},
      },
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "anthropic", -- или "openai", "copilot"
          },
          inline = {
            adapter = "anthropic",
          },
          agent = {
            adapter = "anthropic",
          },
        },

        adapters = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "ANTHROPIC_API_KEY",
              },
            })
          end,

          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = "OPENAI_API_KEY",
              },
            })
          end,

          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "gpt-4",
                },
              },
            })
          end,
        },

        -- Настройки отображения
        display = {
          action_palette = {
            width = 95,
            height = 10,
          },
          chat = {
            window = {
              layout = "vertical", -- или "horizontal", "buffer"
              width = 0.45,
              height = 0.8,
              relative = "editor",
              border = "single",
              title = "CodeCompanion",
            },
            show_settings = true,
            show_token_count = true,
          },
        },

        -- Настройки промптов
        prompt_library = {
          ["Custom Explain"] = {
            strategy = "chat",
            description = "Объясни выделенный код",
            opts = {
              mapping = "<leader>ce", -- Изменено с <LocalLeader>ce
              modes = { "v" },
              short_name = "explain",
              auto_submit = true,
            },
            prompts = {
              {
                role = "user",
                content = function(context)
                  return "Пожалуйста, объясни этот код:\n\n```"
                      .. context.filetype
                      .. "\n"
                      .. require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                      .. "\n```"
                end,
              },
            },
          },

          ["Custom Review"] = {
            strategy = "chat",
            description = "Проведи ревью кода",
            opts = {
              mapping = "<leader>cr", -- Изменено с <LocalLeader>cr
              modes = { "v" },
              short_name = "review",
              auto_submit = true,
            },
            prompts = {
              {
                role = "user",
                content = function(context)
                  return "Пожалуйста, проведи ревью этого кода и дай рекомендации по улучшению:\n\n```"
                      .. context.filetype
                      .. "\n"
                      .. require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                      .. "\n```"
                end,
              },
            },
          },
        },

        -- Настройки агента
        agent = {
          tools = {
            ["filesystem"] = {
              enabled = true,
            },
            ["cmd_runner"] = {
              enabled = true,
            },
          },
        },

        -- Логирование
        log_level = "ERROR", -- "TRACE", "DEBUG", "INFO", "WARN", "ERROR"
      })

      -- Настройка лидеров
      vim.g.mapleader = " "       -- Space как главный лидер
      vim.g.maplocalleader = "\\" -- Backslash как локальный лидер

      -- Горячие клавиши для CodeCompanion
      local map = vim.keymap.set

      -- Основные команды через Space
      map("n", "<leader>cc", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
      map("v", "<leader>cc", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
      map("n", "<leader>ca", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add to Chat" })
      map("v", "<leader>ca", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add to Chat" })

      -- Чат
      map("n", "<leader>co", "<cmd>CodeCompanionChat<cr>", { desc = "Open Chat" })
      map("n", "<leader>ct", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle Chat" })

      -- Inline помощь
      map("v", "<leader>ci", "<cmd>CodeCompanion<cr>", { desc = "Inline CodeCompanion" })

      -- Альтернативные горячие клавиши без лидера
      map("n", "<C-c>c", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
      map("v", "<C-c>c", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
      map("n", "<C-c>o", "<cmd>CodeCompanionChat<cr>", { desc = "Open Chat" })
      map("n", "<C-c>t", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle Chat" })
      map("v", "<C-c>i", "<cmd>CodeCompanion<cr>", { desc = "Inline CodeCompanion" })
    end,
  },

  -- Дополнительные полезные плагины для работы с AI
  {
    "Exafunction/codeium.vim",
    enabled = false, -- Отключен, поскольку используем Copilot
    event = "BufEnter",
    config = function()
      vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-;>', function() return vim.fn['codeium#CycleCompletions'](1) end,
        { expr = true, silent = true })
      vim.keymap.set('i', '<C-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end,
        { expr = true, silent = true })
      vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
    end
  },
}

-- Дополнительные настройки в init.lua или отдельном файле конфигурации:

-- Установка переменных окружения (добавь в ~/.bashrc или ~/.zshrc):
-- export ANTHROPIC_API_KEY="your_anthropic_api_key_here"
-- export OPENAI_API_KEY="your_openai_api_key_here"

-- Или создай файл ~/.config/nvim/lua/config/secrets.lua:
--[[
local M = {}

M.setup = function()
  vim.env.ANTHROPIC_API_KEY = "your_key_here"
  vim.env.OPENAI_API_KEY = "your_key_here"
end

return M
]] --

-- И подключи его в init.lua:
-- require('config.secrets').setup()
