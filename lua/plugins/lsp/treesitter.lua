return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Установка парсеров
    local parsers = {
      -- Основные
      -- "dart", -- Flutter/Dart
      "lua", -- Neovim конфиги
      "vim", -- Vim скрипты
      "vimdoc", -- Vim документация

      -- Документация и заметки
      "markdown",
      "markdown_inline",

      -- Веб (для Flutter Web, документации, и натива)
      "html",
      "css",
      "javascript",
      "typescript",
      "json",
      "jsonc", -- JSON с комментариями
      "kotlin",
      "java",
      "swift",

      -- Конфиги и DevOps
      "yaml",
      "toml",
      "dockerfile",
      "bash",

      -- Git
      "git_config",
      "git_rebase",
      "gitcommit",
      "gitignore",
      "diff",

      -- Дополнительные полезные
      "regex", -- Для регулярок
      "query", -- Treesitter queries
      "sql", -- Если работаешь с БД
      "graphql", -- Если используешь GraphQL API
      "comment", -- Лучшая подсветка комментариев
    }
    require("nvim-treesitter").install(parsers)

    -- Включение подсветки
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        -- "dart",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "html",
        "css",
        "javascript",
        "typescript",
        "json",
        "jsonc",
        "yaml",
        "toml",
        "dockerfile",
        "bash",
        "sh",
        "zsh",
        "gitcommit",
        "gitconfig",
        "gitignore",
        "diff",
        "sql",
        "graphql",
        "kotlin",
        "java",
        "swift",
      },
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    -- Включение отступов "dart"
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "lua", "javascript", "typescript", "json", "yaml", "kotlin", "swift" },
      callback = function()
        pcall(function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })

    -- Сворачивание кода (folding) "dart"
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "kotlin", "swift", "lua", "javascript", "typescript", "json", "yaml" },
      callback = function()
        pcall(function()
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldlevel = 99 -- Открывать все фолды по умолчанию
        end)
      end,
    })

    -- Регистрация парсеров для похожих языков
    vim.treesitter.language.register("bash", "zsh")
    vim.treesitter.language.register("markdown", "mdx")
  end,
}
