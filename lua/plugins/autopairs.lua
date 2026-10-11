return {
    "windwp/nvim-autopairs",
    config = function()
        -- TODO: проверить работу fastWrap
        require("nvim-autopairs").setup({
            check_ts = true,
            fast_wrap = {
                map = "<A-e>", -- Alt + e
                chars = { "{", "[", "(", '"', "'" },
                pattern = [=[[%'%"%>%]%)%}%,]]=],
                end_key = "$",
                before_key = "h",
                after_key = "l",
                cursor_pos_before = true,
                keys = "qwertyuiopzxcvbnmasdfghjkl", -- клавиши-подсказки (hints)
                manual_position = true,
                highlight = "Search",
                highlight_grey = "Comment",
            },
        })
    end,
}
