return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("lint").linters_by_ft = {
      -- Markdown / документация
      markdown = { "markdownlint", "vale" },
      -- Dockerfile
      dockerfile = { "hadolint" },
      -- Shell скрипты
      sh = { "shellcheck" },
      -- YAML (and docker-compose)
      yaml = { "yamllint" },
      -- JSON
      json = { "jsonlint" },
      -- Lua
      lua = { "luacheck" },
      -- Git commit messages (нужен filetype=commitmsg)
      -- gitcommit = { "commitlint" }, -- Раскомментируйте, если установите commitlint
      -- Глобально для всех буферов (орфография)
      ["*"] = { "cspell" },
    }

    -- Автоматический запуск линтинга
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "BufEnter", "InsertLeave" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
