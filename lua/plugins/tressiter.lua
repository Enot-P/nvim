vim.pack.add({
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",

    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "go",
          "gomod",
          "gosum",
          "gotmpl",
          "gowork",
        },

        highlight = { enable = true },
        indent = { enable = true },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },

        textobjects = {
          enable = true,
        },
      })
    end,
  },

  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})
