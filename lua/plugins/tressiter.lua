vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main",
    },

    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})

-- Гарантируем, что плагины на runtimepath до require их модулей.
pcall(vim.cmd, "packadd nvim-treesitter")
pcall(vim.cmd, "packadd nvim-treesitter-textobjects")

-- Языки, которые должны быть установлены.
-- В ветке `main` нет `ensure_installed`/`auto_install` — ставим недостающие вручную.
local ensure_installed = {
    "go",
    "gomod",
    "gosum",
    "gotmpl",
    "gowork",
    "lua",
    "bash",
    "json",
    "markdown",
    "markdown_inline", -- инъекции кода внутри markdown
    "comment",
    "sql", -- покрывает и PostgreSQL-диалект; отдельного `postgresql` парсера нет
    "make",
    "proto",
    "yaml",
}

local function setup_treesitter()
    local ok_ts, ts = pcall(require, "nvim-treesitter")
    if not (ok_ts and ts and type(ts.setup) == "function") then
        return false
    end

    -- install_dir по умолчанию = stdpath('data')/site (там уже лежат парсеры).
    ts.setup()

    -- Доустанавливаем только то, чего ещё нет (аналог auto_install/ensure_installed).
    local installed = {}
    for _, lang in ipairs(ts.get_installed("parsers")) do
        installed[lang] = true
    end
    local missing = {}
    for _, lang in ipairs(ensure_installed) do
        if not installed[lang] then
            missing[#missing + 1] = lang
        end
    end
    if #missing > 0 then
        pcall(function() ts.install(missing) end)
    end

    -- textobjects (ветка main): select / move / swap.
    pcall(function()
        require("nvim-treesitter-textobjects").setup({
            select = { lookahead = true },
            move = { set_jumps = true },
        })
    end)

    return true
end

if not setup_treesitter() then
    vim.api.nvim_create_autocmd("User", {
        pattern = "PackChanged",
        once = true,
        callback = function()
            pcall(vim.cmd, "packadd nvim-treesitter")
            pcall(vim.cmd, "packadd nvim-treesitter-textobjects")
            setup_treesitter()
        end,
    })
end

-- ── Подсветка + indent для любого буфера с доступным парсером ──────────────
-- В ветке `main` highlight/indent не включаются через setup(); делаем это сами.
local function ts_attach(buf)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local ft = vim.bo[buf].filetype
    if ft == "" then return end
    local lang = vim.treesitter.language.get_lang(ft) or ft
    local ok, added = pcall(vim.treesitter.language.add, lang)
    if not (ok and added) then return end
    pcall(vim.treesitter.start, buf, lang)
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_attach", { clear = true }),
    callback = function(args)
        -- http/rest: Kulala регистрирует язык `kulala_http` асинхронно — даём ему успеть.
        if args.match == "http" or args.match == "rest" then
            vim.schedule(function() ts_attach(args.buf) end)
        else
            ts_attach(args.buf)
        end
    end,
})

-- ── Incremental selection ─────────────────────────────────────────────────
-- Модуль удалён из ветки `main`; компактная замена с буфер-локальным стеком нод.
do
    local ts = vim.treesitter
    local stacks = {} ---@type table<integer, TSNode[]>

    local function same_range(a, b)
        local a1, a2, a3, a4 = a:range()
        local b1, b2, b3, b4 = b:range()
        return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
    end

    local function select_node(node)
        local srow, scol, erow, ecol = node:range()
        -- treesitter end-col эксклюзивный; приводим к visual (1-based, inclusive).
        if ecol == 0 then
            erow = erow - 1
            ecol = #(vim.api.nvim_buf_get_lines(0, erow, erow + 1, true)[1] or "")
        end
        ecol = math.max(ecol - 1, 0)
        -- Выходим из visual, если он уже активен, иначе `v` его выключит.
        if vim.fn.mode():match("[vV\22]") then
            vim.cmd("normal! \27")
        end
        vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
        vim.cmd("normal! v")
        vim.api.nvim_win_set_cursor(0, { erow + 1, ecol })
    end

    local function get_stack()
        local b = vim.api.nvim_get_current_buf()
        stacks[b] = stacks[b] or {}
        return stacks[b]
    end

    local function init_selection()
        local node = ts.get_node()
        if not node then return end
        local s = get_stack()
        for i = #s, 1, -1 do s[i] = nil end
        s[1] = node
        select_node(node)
    end

    local function grow()
        local s = get_stack()
        local cur = s[#s] or ts.get_node()
        if not cur then return end
        local parent = cur:parent()
        while parent and same_range(parent, cur) do
            parent = parent:parent()
        end
        if not parent then return end
        s[#s + 1] = parent
        select_node(parent)
    end

    local function shrink()
        local s = get_stack()
        if #s <= 1 then return end
        s[#s] = nil
        select_node(s[#s])
    end

    local opts = { silent = true }
    vim.keymap.set("n", "gnn", init_selection, opts) -- init_selection
    vim.keymap.set("x", "grn", grow, opts) -- node_incremental
    vim.keymap.set("x", "grc", grow, opts) -- scope_incremental (отдельной scope-семантики в core нет)
    vim.keymap.set("x", "grm", shrink, opts) -- node_decremental
end
