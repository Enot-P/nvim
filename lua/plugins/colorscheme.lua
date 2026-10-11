-- priority = 1000: тема грузится раньше остальных плагинов, чтобы их
-- nvim_set_hl (dap, multicursor, tiny-cmdline) ложились поверх неё, а не наоборот.
return {
    {
        "olimorris/onedarkpro.nvim",
        priority = 1000,
        config = function() require("onedarkpro").setup({}) end,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                dark_variant = "moon", -- main, moon, or dawn
            })
            -- vim.cmd.colorscheme("vaporwave")
            vim.cmd("colorscheme rose-pine")
        end,
    },
}
