vim.pack.add {
    { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' }
}

require("ibl").setup({
    indent = {
        char = "▎",        --  "│", "▏", "|"  
    },

    scope = {
        enabled = true,
        show_start = true,
        show_end = true,
        show_exact_scope = false,
        highlight = { "IblScope" },
    },
})
