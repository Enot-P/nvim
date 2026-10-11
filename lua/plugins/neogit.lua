return {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim", "folke/snacks.nvim" },
    config = function()
        require("neogit").setup({
            -- "unicode" рисует граф лога рамками; "kitty" красивее, но требует
            -- поддержки графики терминалом, "ascii" — запасной вариант.
            graph_style = "unicode",
            integrations = {
                -- Свои диффы Neogit показывает только инлайн; попап диффа даёт diffview.
                diffview = true,
                -- Меню выбора (ветки, ремоуты, файлы) — через snacks.picker.
                snacks = true,
            },
        })

        -- <leader>gg занят lazygit, поэтому Neogit живёт на gn.
        vim.keymap.set("n", "<leader>gn", "<cmd>Neogit<cr>", { desc = "Neogit (magit-like)" })
        vim.keymap.set("n", "<leader>gc", "<cmd>Neogit commit<cr>", { desc = "Neogit commit" })
    end,
}
