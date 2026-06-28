vim.pack.add({
    { src = "https://github.com/coder/claudecode.nvim" },
})

require("claudecode").setup({
    auto_start = true,
    log_level = "warn",
    track_selection = true,
    focus_after_send = true, -- после отправки выделения курсор сразу в терминал Claude

    terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
        provider = "snacks",
        auto_close = true,
        auto_insert = true,
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
    },

    diff_opts = {
        -- "unified" = инлайн-дифф в стиле VS Code; "vertical" = side-by-side; "horizontal" = сверху/снизу
        layout = "unified",
        open_in_new_tab = false, -- true = каждый дифф в отдельной вкладке
        keep_terminal_focus = false, -- true = фокус остаётся в терминале при открытии диффа
    },

    -- актуализируем список моделей (дефолт плагина устарел: Opus 4.1 / Sonnet 4.5)
    models = {
        { name = "Claude Opus 4.8 (Latest)", value = "opus" },
        { name = "Claude Sonnet 4.6 (Latest)", value = "sonnet" },
        { name = "Opusplan (Opus + Sonnet)", value = "opusplan" },
        { name = "Claude Haiku 4.5", value = "haiku" },
    },
})

local map = vim.keymap.set

vim.keymap.set("n", "<leader>a", "", { desc = "+claude" })
map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })

-- выделить блок кода в visual и спросить по нему: выделение уходит как контекст,
-- focus_after_send ставит курсор в терминал — сразу печатаешь вопрос
map({ "n", "v" }, "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection" })

map("n", "<leader>aA", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current file" })
map("n", "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
map("n", "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

-- новые удобные команды
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume session" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue last" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select model" })
