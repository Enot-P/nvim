vim.pack.add({
    "https://github.com/potamides/pantran.nvim",
})

-- Порог кириллицы для определения языка (0.0 - 1.0)
local CYRILLIC_THRESHOLD = 0.3

local function detect_language(text)
    local total = 0
    local cyrillic = 0

    for _ in text:gmatch("[%z\1-\127\194-\253][\128-\191]*") do
        total = total + 1
    end
    for _ in text:gmatch("[\208-\209][\128-\191]") do
        cyrillic = cyrillic + 1
    end

    if total == 0 then
        return "en"
    end
    return (cyrillic / total) >= CYRILLIC_THRESHOLD and "ru" or "en"
end

local function detect_and_translate(opts)
    return function()
        local mode = vim.fn.mode()
        local text = ""

        if mode == "v" or mode == "V" or mode == "\22" then
            local start_pos = vim.fn.getpos("'<")
            local end_pos = vim.fn.getpos("'>")
            local lines = vim.fn.getregion(start_pos, end_pos, { type = vim.fn.visualmode() })
            text = table.concat(lines, " ")
        else
            text = vim.fn.expand("<cword>")
        end

        text = text:gsub("[\t\n\r]+", " "):gsub("^%s+", ""):gsub("%s+$", "")

        local source = detect_language(text)
        local target = source == "ru" and "en" or "ru"

        local translate_opts = vim.tbl_extend("force", {
            source = source,
            target = target,
        }, opts or {})

        return require("pantran").motion_translate(translate_opts)
    end
end

require("pantran").setup({
    default_engine = "yandex",
    engines = {
        yandex = {
            auth_key = os.getenv("YANDEX_API_KEY"),
            default_source = "auto",
            default_target = "ru",
        },
    },
    ui = {
        width_percentage = 0.9,
        height_percentage = 0.5,
    },
    controls = {
        mappings = {
            edit = {
                n = {
                    ["j"] = "gj",
                    ["k"] = "gk",
                    ["<C-c>"] = require("pantran.ui.actions").close,
                },
                i = {
                    ["<C-y>"] = false,
                    ["<C-a>"] = require("pantran.ui.actions").yank_close_translation,
                    ["<C-c>"] = require("pantran.ui.actions").close,
                },
            },
            select = {
                n = {
                    ["<C-c>"] = require("pantran.ui.actions").close,
                },
            },
        },
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "pantran",
    callback = function(ev)
        vim.api.nvim_buf_set_keymap(ev.buf, "n", "<C-c>", "", {
            callback = function() require("pantran.ui.actions").close() end,
            noremap = true,
            silent = true,
        })
        vim.api.nvim_buf_set_keymap(ev.buf, "i", "<C-c>", "", {
            callback = function() require("pantran.ui.actions").close() end,
            noremap = true,
            silent = true,
        })

        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
            buffer = ev.buf,
            callback = function()
                local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
                local changed = false
                for i, line in ipairs(lines) do
                    local clean = line:gsub("\t", " "):gsub("^%s+", ""):gsub("%s+$", "")
                    if clean ~= line then
                        lines[i] = clean
                        changed = true
                    end
                end
                if changed then
                    vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, lines)
                end
            end,
        })
    end,
})

-- Универсальные маппинги с автоопределением языка
vim.keymap.set(
    "n",
    "<leader>tt",
    detect_and_translate(),
    { noremap = true, silent = true, expr = true, desc = "Translate motion (auto)" }
)
vim.keymap.set(
    "n",
    "<leader>ttt",
    function() return detect_and_translate()() .. "_" end,
    { noremap = true, silent = true, expr = true, desc = "Translate current line (auto)" }
)
vim.keymap.set(
    "x",
    "<leader>tt",
    detect_and_translate(),
    { noremap = true, silent = true, expr = true, desc = "Translate selection (auto)" }
)

-- Явные маппинги на случай если нужно переопределить направление
vim.keymap.set(
    "n",
    "<leader>ttr",
    function() return require("pantran").motion_translate({ source = "en", target = "ru" }) end,
    { noremap = true, silent = true, expr = true, desc = "Translate motion (EN→RU)" }
)
vim.keymap.set(
    "x",
    "<leader>ttr",
    function() return require("pantran").motion_translate({ source = "en", target = "ru" }) end,
    { noremap = true, silent = true, expr = true, desc = "Translate selection (EN→RU)" }
)
vim.keymap.set(
    "n",
    "<leader>tte",
    function() return require("pantran").motion_translate({ source = "ru", target = "en" }) end,
    { noremap = true, silent = true, expr = true, desc = "Translate motion (RU→EN)" }
)
vim.keymap.set(
    "x",
    "<leader>tte",
    function() return require("pantran").motion_translate({ source = "ru", target = "en" }) end,
    { noremap = true, silent = true, expr = true, desc = "Translate selection (RU→EN)" }
)

require("which-key").add({
    { "<leader>tt", group = "Translate" },
    { "<leader>ttr", desc = "Translate (EN→RU)" },
    { "<leader>tte", desc = "Translate (RU→EN)" },
})
