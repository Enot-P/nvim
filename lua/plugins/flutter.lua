vim.pack.add({
    { src = "https://github.com/nvim-flutter/flutter-tools.nvim" },
})

require("flutter-tools").setup({
    closing_tags = {
        highlight = "Comment",
        prefix = " 󰅂 ",
        enabled = true,
    },
    dev_log = {
        enabled = true,
        notify_errors = true,
        open_cmd = "vsplit",
    },
    outline = {
        open_cmd = "30vnew",
        auto_open = false,
    },
    lsp = {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
        },
    },
})

-- Which-key группа
require("which-key").add({
    { "<leader>fl", group = "Flutter" },
})

-- Шоткаты
local map = function(keys, cmd, desc) vim.keymap.set("n", keys, cmd, { desc = desc, silent = true }) end

-- Запуск / управление
map("<leader>flr", "<cmd>FlutterRun<cr>", "Run")
map("<leader>flR", "<cmd>FlutterRestart<cr>", "Restart")
map("<leader>flh", "<cmd>FlutterReload<cr>", "Hot Reload")
map("<leader>flq", "<cmd>FlutterQuit<cr>", "Quit")
map("<leader>fld", "<cmd>FlutterDebug<cr>", "Debug")

-- Устройства / эмуляторы
map("<leader>flD", "<cmd>FlutterDevices<cr>", "Devices")
map("<leader>fle", "<cmd>FlutterEmulators<cr>", "Emulators")

-- UI / инспектор
map("<leader>flo", "<cmd>FlutterOutlineToggle<cr>", "Outline")
map("<leader>flv", "<cmd>FlutterVisualDebug<cr>", "Visual Debug")
map("<leader>fli", "<cmd>FlutterInspectWidget<cr>", "Inspect Widget")

-- Логи
map("<leader>fll", "<cmd>FlutterLogToggle<cr>", "Log Toggle")
map("<leader>flL", "<cmd>FlutterLogClear<cr>", "Log Clear")

-- LSP / прочее
map("<leader>fls", "<cmd>FlutterSuper<cr>", "Go to Super")
map("<leader>fla", "<cmd>FlutterReanalyze<cr>", "Reanalyze")
map("<leader>fln", "<cmd>FlutterRename<cr>", "Rename")
map("<leader>flp", "<cmd>FlutterPubGet<cr>", "Pub Get")
map("<leader>flP", "<cmd>FlutterPubUpgrade<cr>", "Pub Upgrade")
