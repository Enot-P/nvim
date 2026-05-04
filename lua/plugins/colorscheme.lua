vim.pack.add({
    { src = "https://github.com/olimorris/onedarkpro.nvim" },
    {
        src = "https://github.com/rose-pine/neovim",
        name = "rose-pine",
    },
})

require("onedarkpro").setup({})
require("rose-pine").setup({
    dark_variant = "moon", -- main, moon, or dawn
})
-- vim.cmd.colorscheme("vaporwave")
vim.cmd("colorscheme rose-pine")
