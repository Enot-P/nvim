return {
    "chojs23/ec",
    config = function()
        local ok, ec = pcall(require, "ec")
        if ok then
            ec.setup({})
        end

        vim.keymap.set("n", "<leader>gr", ":Ec<CR>", { desc = "Open ec conflict resolver" })
    end,
}
