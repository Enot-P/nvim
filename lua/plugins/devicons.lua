return {
    "nvim-tree/nvim-web-devicons",
    config = function()
        require("nvim-web-devicons").setup({
            override = {},
            default = true,
            color_icons = true,
            strict = false,
        })
    end,
}
