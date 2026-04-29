vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
    { src = "https://github.com/nvim-neotest/neotest" },
    { src = "https://github.com/nvim-neotest/neotest-go" },
})

require("neotest").setup({
    adapters = {
        require("neotest-go")({}),
    },
    output_panel = {
        enabled = true,
        open = "botright split | resize 15",
    },
})

-- Группа <leader>t для which-key
vim.keymap.set("n", "<leader>t", "", { desc = "+test" })

vim.keymap.set("n", "<leader>tr", function()
    require("neotest").run.run()
    require("neotest").output_panel.open()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
    require("neotest").run.run(vim.fn.expand("%"))
    require("neotest").output_panel.open()
end, { desc = "Run all tests in file" })

vim.keymap.set("n", "<leader>tl", function()
    require("neotest").run.run_last()
    require("neotest").output_panel.open()
end, { desc = "Re-run last test" })

vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle test summary" })

vim.keymap.set(
    "n",
    "<leader>to",
    function() require("neotest").output_panel.toggle() end,
    { desc = "Toggle output panel" }
)

vim.keymap.set(
    "n",
    "<leader>tO",
    function() require("neotest").output.open({ enter = true }) end,
    { desc = "Open test output" }
)

vim.keymap.set("n", "<leader>tx", function() require("neotest").run.stop() end, { desc = "Stop test" })

vim.keymap.set(
    "n",
    "<leader>tw",
    function() require("neotest").watch.toggle(vim.fn.expand("%")) end,
    { desc = "Watch test file" }
)
