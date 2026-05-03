vim.pack.add({
    { src = "https://github.com/chojs23/ec" },
})

local ok, ec = pcall(require, "ec")
if ok then
    ec.setup({})
end

vim.keymap.set("n", "<leader>gr", ":Ec<CR>", { desc = "Open ec conflict resolver" })
