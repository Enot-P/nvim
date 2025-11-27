-- This file now contains the configuration for nvim-treesitter and its related plugins.
return {
  -- Main Treesitter plugin
  {
    "nvim-treesitter/nvim-treesitter",
    -- We declare the other plugins as dependencies.
    -- lazy.nvim will load them automatically.
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- The setup call now includes the configuration for textobjects,
      -- which was previously in a separate file.
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "dart",
          "lua",
          "javascript",
          "typescript",
          "tsx",
          "json",
          "html",
          "css",
          "scss",
          "yaml",
          "bash",
        },
        auto_install = true,
        highlight = {
          enable = true,
          -- Добавляем защиту от ошибок подсветки
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
            
            -- Проверяем на проблемные символы
            local lines = vim.api.nvim_buf_get_lines(buf, 0, math.min(100, vim.api.nvim_buf_line_count(buf)), false)
            for _, line in ipairs(lines) do
              -- Проверяем на очень длинные строки
              if #line > 2000 then
                return true
              end
              -- Проверяем на подозрительные символы (упрощенная проверка)
              for i = 1, #line do
                local char = line:sub(i, i)
                local byte = char:byte()
                if byte < 32 or byte == 127 then
                  return true
                end
              end
            end
            
            return false
          end,
          -- Дополнительные настройки для стабильности
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        -- Configuration for nvim-treesitter-textobjects
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },

  -- Treesitter Context plugin
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 0,
        -- Добавляем защиту от ошибок
        patterns = {
          default = {
            "class",
            "function",
            "method",
          },
        },
        -- Дополнительные настройки для стабильности
        zindex = 20,
        mode = "cursor",
        separator = nil,
      })
    end,
  },
}