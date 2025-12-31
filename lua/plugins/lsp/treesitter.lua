return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Автоматическая установка парсеров при открытии файла
      ensure_installed = {
        -- Основные
        "dart", -- Flutter/Dart
        "lua", -- Neovim конфиги
        "vim", -- Vim скрипты
        "vimdoc", -- Vim документация

        -- Документация и заметки
        "markdown",
        "markdown_inline",

        -- Веб
        "html",
        "css",
        "javascript",
        "typescript",
        "json",
        "kotlin",
        "java",
        -- "swift",

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

        -- Дополнительные
        "regex",
        "query",
        "sql",
        "graphql",
        "comment",
      },

      -- Автоматическая установка при открытии нового типа файла
      auto_install = true,

      -- Подсветка синтаксиса
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      -- Улучшенные отступы
      indent = {
        enable = true,
      },

      -- Инкрементальное выделение
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<S-CR>",
          node_decremental = "<BS>",
        },
      },
    })

    -- Сворачивание кода через Treesitter
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldenable = false -- Не сворачивать при открытии
    vim.opt.foldlevel = 99

    -- Регистрация парсеров для похожих языков
    vim.treesitter.language.register("bash", "zsh")
    vim.treesitter.language.register("markdown", "mdx")
  end,
}
