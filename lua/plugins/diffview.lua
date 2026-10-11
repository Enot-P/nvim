return {
    "sindrets/diffview.nvim",
    config = function()
        require("diffview").setup({})

        vim.keymap.set("n", "<leader>od", function()
            if next(require("diffview.lib").views) == nil then
                vim.cmd("DiffviewOpen")
            else
                vim.cmd("DiffviewClose")
            end
        end, { desc = "Toggle diffview" })
    end,
}
