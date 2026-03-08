return {
    {
        "olexsmir/gopher.nvim",
        ft = "go",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            commands = {
                go = "go",
                gomodifytags = "gomodifytags",
                gotests = "gotests",
                impl = "impl",
            },
        },
        config = function(_, opts)
            local ok, gopher = pcall(require, "gopher")
            if not ok then
                return
            end
            gopher.setup(opts)

            -- Не используем <leader>gt* (зарезервировано под neotest-go)
            vim.keymap.set("n", "<leader>goj", "<cmd>GoTagAdd json<CR>", { desc = "Go: добавить json теги" })
            vim.keymap.set("n", "<leader>gox", "<cmd>GoTagAdd xml<CR>", { desc = "Go: добавить xml теги" })
            vim.keymap.set("n", "<leader>goe", "<cmd>GoIfErr<CR>", { desc = "Go: обернуть в if err" })
            vim.keymap.set("n", "<leader>goi", "<cmd>GoImpl<CR>", { desc = "Go: сгенерировать реализацию интерфейса" })
            vim.keymap.set("n", "<leader>got", "<cmd>GoTestsAll<CR>", { desc = "Go: сгенерировать тесты для файла" })
            vim.keymap.set("n", "<leader>gor", function()
                local file = vim.fn.expand("%:p")
                local cmd = { "go", "run", file }
                Snacks.terminal(cmd, {
                    auto_close = false,
                    title = "go run " .. vim.fn.expand("%"),
                })
            end, { desc = "Побыстрому запустить" })
        end,
    },
}
