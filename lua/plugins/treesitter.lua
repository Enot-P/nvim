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
      })
    end,
  },
}