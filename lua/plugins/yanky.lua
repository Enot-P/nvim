vim.pack.add({
    { src = "https://github.com/gbprod/yanky.nvim" },
})

require("yanky").setup({
    ring = {
        history_length = 100,
        storage = "shada",
        sync_with_numbered_registers = true,
        cancel_event = "update",
        ignore_registers = { "_" },
        update_register_on_cycle = false,
        permanent_wrapper = nil,
    },
    system_clipboard = {
        sync_with_ring = true,
    },
})

-- Базовые кеймапы для yank ring (обязательно!)
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")

-- Snacks picker для истории yanks
vim.keymap.set({ "n", "x" }, "<leader>p", function() Snacks.picker.yanky() end, { desc = "Open Yank History" })
