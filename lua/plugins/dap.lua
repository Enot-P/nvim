vim.pack.add({
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/leoluz/nvim-dap-go" },
})

local dap = require("dap")
local dapui = require("dapui")

dapui.setup()
require("dap-go").setup({
    tests = { verbose = true },
})

dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

local map = vim.keymap.set
map("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
map("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
map("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
map("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
map("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })

map("n", "<leader>dB", function()
    dap.clear_breakpoints()
    vim.notify("All breakpoints were cleared", vim.log.levels.INFO)
end, { desc = "Debug: Clear all breakpoints" })

----  Golang ------
map("n", "<leader>dt", require("dap-go").debug_test, { desc = "Debug: Test under cursor" })
map("n", "<leader>dT", require("dap-go").debug_last_test, { desc = "Debug: Repeat last test" })

----------- SETTINGS -------------
vim.fn.sign_define("DapBreakpoint", {
    text = "●",
    texthl = "DapBreakpoint",
    linehl = "",
    numhl = "",
})
vim.fn.sign_define("DapBreakpointCondition", {
    text = "◆",
    texthl = "DapBreakpointCondition",
    linehl = "",
    numhl = "",
})
vim.fn.sign_define("DapStopped", {
    text = "▶",
    texthl = "DapStopped",
    linehl = "DapStoppedLine", -- подсветка всей строки
    numhl = "DapStopped",
})
vim.fn.sign_define("DapBreakpointRejected", {
    text = "○",
    texthl = "DapBreakpointRejected",
    linehl = "",
    numhl = "",
})

-- Цвета
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" }) -- красный
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5c07b" }) -- жёлтый
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" }) -- зелёный
vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#5c6370" }) -- серый
vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e3a2e" }) -- тёмно-зелёный фон

-- Курсор следит за текущей строкой выполнения
dap.listeners.after.event_stopped["cursor_follow"] = function(session)
    local frame = session and session.current_frame
    if not frame then
        return
    end
    local path = frame.source and frame.source.path
    if not path then
        return
    end
    vim.schedule(function()
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        vim.api.nvim_win_set_cursor(0, { frame.line, 0 })
        vim.cmd("normal! zz") -- центрировать экран
    end)
end
