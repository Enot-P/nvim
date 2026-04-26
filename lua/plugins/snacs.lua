vim.pack.add({ "https://github.com/folke/snacks.nvim" })

local snacks = require("snacks")

snacks.setup({
    bigfile = { enabled = true },
    terminal = {
        win = {
            position = "float",
            border = "rounded",
            backdrop = 70,
            width = 0.85,
            height = 0.80,
            zindex = 60,
        },
        stack = true,
        bo = { filetype = "snacks_terminal" },
        keys = {
            q = "hide",
            term_toggle = {
                { "<C-/>", "<C-_>", "<leader>t" },
                function() snacks.terminal() end,
                mode = "t",
                expr = true,
                desc = "Toggle Terminal",
            },
            term_toggle_alt = {
                "<C-_>",
                function() snacks.terminal() end,
                mode = "t",
                expr = true,
                desc = "which_key_ignore",
            },
        },
    },
    styles = {
        float = {
            backdrop = 65,
            border = "rounded",
            zindex = 50,
        },
    },
    dashboard = {
        enabled = true,
        preset = {
            header = [[
⠀⠀⠀⠀⠀⠀⠀⠰⣶⣶⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢰⣿⡟⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣀⣼⣿⣀⣹⣿⡆⠀⢤⡄⢤⣄⢤⡤⠀⢤⣤⣤⣤⣤⢤⣄⠀⢤⣤⡤⣤⣤⣤⢠⡄⠀⣤⢤⡤⢤⡠⣤⠤⣴⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⢹⣿⡇⠉⠉⢿⣿⡄⢸⡇⠀⢹⡏⢿⣠⡟⢹⣿⠤⠄⢸⡿⣷⣼⡇⠀⣿⡇⠀⢸⡇⠀⡇⢸⡇⣎⠀⣿⠶⠌⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡴⠾⠿⠀⠀⠀⠘⠿⠿⠾⠿⠴⠛⠁⠘⠏⠀⠼⠿⠦⠖⠸⠃⠀⠙⠇⠀⠿⠇⠀⠘⠷⠚⠇⠾⠇⠘⠿⠿⠶⠶⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣀⠀⠀⣤⣤⣤⣤⣤⣤⣤⣤⣤⡄⢠⣤⡤⠀⢲⣶⣶⡄⠀⠀⠀⣰⣶⣶⠖⠀⢲⣶⣶⠶⠶⢶⣶⠀⠀⠀⠀
⢀⣀⠀⠀⠀⠀⠀⢀⣸⣿⣉⣀⠀⢟⡉⠉⡉⣿⣿⢉⣉⣙⣛⣘⣿⣇⣀⡀⣿⢿⣿⡄⠀⣼⡿⣿⣿⢠⣤⣬⣭⣭⣤⣤⣤⣬⣤⣤⣀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⢇⣿⠰⠻⣿⣾⡿⠵⣿⣿⠸⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠟⠁
⠀⠀⠀⠀⠀⠀⠀⠉⢹⣿⣍⠁⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⢰⣶⡆⠀⣼⣿⡆⠀⠹⡿⠁⠀⣿⣿⡀⠀⣸⣿⣿⣤⣤⣤⣤⡆⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠉⠀⠀⠀⠀⠀⠴⠟⠛⠂⠀⠀⠀⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠛⠻⠋⠀⠀⠀⠀
            ]],
        },
        sections = {
            { section = "header" },
            { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
            { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
            { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        },
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = {
        sources = {
            explorer = {
                auto_close = true,
                replace_netrw = true,
                trash = true,
                layout = "right",
                hidden = true,
                git_untracked = false,
            },
        },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
})

-- ── Keymaps ───────────────────────────────────────────────────────────────────
local map = vim.keymap.set

-- Top Pickers & Explorer
map("n", "<leader><space>", function() snacks.picker.smart() end, { desc = "Smart Find Files" })
map("n", "<leader>/", function() snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>nn", function() snacks.picker.notifications() end, { desc = "Notification History" })
map("n", "<leader>e", function() snacks.explorer() end, { desc = "File Explorer" })

-- find
map("n", "<leader>fb", function() snacks.picker.buffers() end, { desc = "Buffers" })
map(
    "n",
    "<leader>fc",
    function() snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
    { desc = "Find Config File" }
)
map("n", "<leader>ff", function() snacks.picker.files() end, { desc = "Find Files" })
map("n", "<leader>fg", function() snacks.picker.git_files() end, { desc = "Find Git Files" })
map("n", "<leader>fp", function() snacks.picker.projects() end, { desc = "Projects" })
map("n", "<leader>fr", function() snacks.picker.recent() end, { desc = "Recent" })

-- git
map("n", "<leader>gb", function() snacks.picker.git_branches() end, { desc = "Git Branches" })
map("n", "<leader>gl", function() snacks.picker.git_log() end, { desc = "Git Log" })
map("n", "<leader>gL", function() snacks.picker.git_log_line() end, { desc = "Git Log Line" })
map("n", "<leader>gs", function() snacks.picker.git_status() end, { desc = "Git Status" })
map("n", "<leader>gS", function() snacks.picker.git_stash() end, { desc = "Git Stash" })
map("n", "<leader>gd", function() snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
map("n", "<leader>gf", function() snacks.picker.git_log_file() end, { desc = "Git Log File" })

-- gh
map("n", "<leader>gi", function() snacks.picker.gh_issue() end, { desc = "GitHub Issues (open)" })
map("n", "<leader>gI", function() snacks.picker.gh_issue({ state = "all" }) end, { desc = "GitHub Issues (all)" })
map("n", "<leader>gp", function() snacks.picker.gh_pr() end, { desc = "GitHub Pull Requests (open)" })
map("n", "<leader>gP", function() snacks.picker.gh_pr({ state = "all" }) end, { desc = "GitHub Pull Requests (all)" })

-- grep
map("n", "<leader>sb", function() snacks.picker.lines() end, { desc = "Buffer Lines" })
map("n", "<leader>sB", function() snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
map("n", "<leader>sg", function() snacks.picker.grep() end, { desc = "Grep" })
map({ "n", "x" }, "<leader>sw", function() snacks.picker.grep_word() end, { desc = "Visual selection or word" })

-- search
map("n", '<leader>s"', function() snacks.picker.registers() end, { desc = "Registers" })
map("n", "<leader>s/", function() snacks.picker.search_history() end, { desc = "Search History" })
map("n", "<leader>sa", function() snacks.picker.autocmds() end, { desc = "Autocmds" })
map("n", "<leader>sc", function() snacks.picker.command_history() end, { desc = "Command History" })
map("n", "<leader>sC", function() snacks.picker.commands() end, { desc = "Commands" })
map("n", "<leader>sd", function() snacks.picker.diagnostics() end, { desc = "Diagnostics" })
map("n", "<leader>sD", function() snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
map("n", "<leader>sh", function() snacks.picker.help() end, { desc = "Help Pages" })
map("n", "<leader>sH", function() snacks.picker.highlights() end, { desc = "Highlights" })
map("n", "<leader>si", function() snacks.picker.icons() end, { desc = "Icons" })
map("n", "<leader>sj", function() snacks.picker.jumps() end, { desc = "Jumps" })
map("n", "<leader>sk", function() snacks.picker.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>sl", function() snacks.picker.loclist() end, { desc = "Location List" })
map("n", "<leader>sm", function() snacks.picker.marks() end, { desc = "Marks" })
map("n", "<leader>sM", function() snacks.picker.man() end, { desc = "Man Pages" })
map("n", "<leader>sp", function() snacks.picker.lazy() end, { desc = "Search for Plugin Spec" })
map("n", "<leader>sq", function() snacks.picker.qflist() end, { desc = "Quickfix List" })
map("n", "<leader>sR", function() snacks.picker.resume() end, { desc = "Resume" })
map("n", "<leader>su", function() snacks.picker.undo() end, { desc = "Undo History" })
map("n", "<leader>uC", function() snacks.picker.colorschemes() end, { desc = "Colorschemes" })

-- LSP
map("n", "gd", function() snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
map("n", "gD", function() snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
map("n", "gr", function() snacks.picker.lsp_references() end, { desc = "References", nowait = true })
map("n", "gI", function() snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
map("n", "gy", function() snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
map("n", "gai", function() snacks.picker.lsp_incoming_calls() end, { desc = "Calls Incoming" })
map("n", "gao", function() snacks.picker.lsp_outgoing_calls() end, { desc = "Calls Outgoing" })
map("n", "<leader>ss", function() snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
map("n", "<leader>sS", function() snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })

-- Other
map("n", "<leader>z", function() snacks.zen() end, { desc = "Toggle Zen Mode" })
map("n", "<leader>Z", function() snacks.zen.zoom() end, { desc = "Toggle Zoom" })
map("n", "<leader>.", function() snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function() snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
map("n", "<leader>n", function() snacks.notifier.show_history() end, { desc = "Notification History" })
map("n", "<A-q>", function() snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>cR", function() snacks.rename.rename_file() end, { desc = "Rename File" })
map({ "n", "v" }, "<leader>gB", function() snacks.gitbrowse() end, { desc = "Git Browse" })
map("n", "<leader>gg", function() snacks.lazygit() end, { desc = "Lazygit" })
map("n", "<leader>un", function() snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })
map({ "n", "t" }, "<C-/>", function() snacks.terminal() end, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-_>", function() snacks.terminal() end, { desc = "Toggle Terminal" })
map("n", "<C-_>", function() snacks.terminal() end, { desc = "which_key_ignore" })

vim.opt.timeoutlen = 50
map({ "n", "t" }, "]]", function() snacks.words.jump(vim.v.count1) end, { desc = "Next Reference" })
map({ "n", "t" }, "[[", function() snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })

vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        _G.dd = function(...) snacks.debug.inspect(...) end
        _G.bt = function() snacks.debug.backtrace() end

        if vim.fn.has("nvim-0.11") == 1 then
            vim._print = function(_, ...) dd(...) end
        else
            vim.print = _G.dd
        end

        snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        snacks.toggle.diagnostics():map("<leader>ud")
        snacks.toggle.line_number():map("<leader>ul")
        snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
        snacks.toggle.treesitter():map("<leader>uT")
        snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        snacks.toggle.indent():map("<leader>ug")
        snacks.toggle.dim():map("<leader>uD")
    end,
})
