return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  after = "treesitter.lua",
  config = function()
    require("nvim-treesitter.configs").setup {
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj if the cursor is on a blank line.
          keymaps = {
            -- You can use the default keymaps or define your own
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
      },
    }
  end,
}