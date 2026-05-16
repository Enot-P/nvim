vim.opt.spell = true
vim.opt.spelllang = { "ru", "en_us" }
vim.opt.spelloptions:append("camel")

-- Вызов меню предложений Telescope
vim.keymap.set("n", "<leader>ca", function()
    require("telescope.builtin").spell_suggest(
        require("telescope.themes").get_cursor({}) -- Откроет меню прямо у курсора
    )
end, { desc = "Исправления орфографии" })
