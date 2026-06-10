vim.pack.add({
    { src = "https://github.com/coder/claudecode.nvim" },
})

require("claudecode").setup({
    auto_start = true,
    log_level = "warn",
    track_selection = true,
    focus_after_send = true,
    split_side = "right",
    split_width_percentage = 0.35,
    provider = "snacks",
    snacks_win_opts = {
        position = "right",
        width = 0.35,
        border = "rounded",
        keys = {
            claude_hide = {
                "q",
                function(self) self:hide() end,
                mode = "t",
            },
        },
    },
})

local map = vim.keymap.set

vim.keymap.set("n", "<leader>a", "", { desc = "+claude" })
map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
map({ "n", "v" }, "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection" })
map("n", "<leader>aA", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current file" })
map("n", "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
map("n", "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })
