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
    debugger = {
        enabled = true,
        run_via_dap = true,
        exception_breakpoints = {},
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

-- ============================================================
-- 🛢 Barrel Create — dart export generator
-- ============================================================

local function find_project_root(dir)
    local pubspec = vim.fs.find({ "pubspec.yaml" }, { upward = true, path = dir })[1]
    return pubspec and vim.fn.fnamemodify(pubspec, ":h") or nil
end

local function has_barrel_create()
    local f = io.popen("dart pub global list 2>/dev/null")
    if not f then
        return false
    end
    local out = f:read("*a")
    f:close()
    return out:find("barrel_create") ~= nil
end

local function run_barrel_create(dir)
    local root = find_project_root(dir)
    if not root then
        vim.notify("Not a Dart project (no pubspec.yaml found)", vim.log.levels.WARN)
        return
    end
    if not has_barrel_create() then
        vim.notify("barrel_create not installed. Run: dart pub global activate barrel_create", vim.log.levels.WARN)
        return
    end
    local rel = dir:sub(#root + 2)
    vim.fn.jobstart({ "barrel_create", rel }, {
        cwd = root,
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                if line and line ~= "" then
                    vim.notify(line, vim.log.levels.INFO)
                end
            end
        end,
        on_stderr = function(_, data)
            for _, line in ipairs(data) do
                if line and line ~= "" then
                    vim.notify(line, vim.log.levels.WARN)
                end
            end
        end,
        on_exit = function(_, code)
            if code == 0 then
                vim.notify("✅ Barrel files created in " .. dir, vim.log.levels.INFO)
            else
                vim.notify("❌ barrel_create failed (code " .. code .. ")", vim.log.levels.ERROR)
            end
        end,
    })
end

-- Add action and key to snacks.explorer via the live config
---@diagnostic disable-next-line: undefined-field
local exp_config = require("snacks").config.picker.sources.explorer
exp_config.actions = exp_config.actions or {}
exp_config.actions.dart_barrel_create = function(picker, item)
    local dir = (item.dir and item.file)
        or (item.file and vim.fn.isdirectory(item.file) == 1 and item.file)
        or picker:dir()
    run_barrel_create(dir)
end
exp_config.win = exp_config.win or {}
exp_config.win.list = exp_config.win.list or {}
exp_config.win.list.keys = exp_config.win.list.keys or {}
exp_config.win.list.keys["ge"] = "dart_barrel_create"
