vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main",
    },

    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})

-- Ensure plugin is on runtimepath before requiring its modules.
pcall(vim.cmd, "packadd nvim-treesitter")

local function setup_treesitter()
    local opts = {
        ensure_installed = {
            "go",
            "gomod",
            "gosum",
            "gotmpl",
            "gowork",
            "lua",
            "bash",
            "json",
            "markdown",
            "comment",
            "sql",
            "postgresql",
            "make",
            "proto",
        },
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "gnn",
                node_incremental = "grn",
                scope_incremental = "grc",
                node_decremental = "grm",
            },
        },
        textobjects = { enable = true },
    }

    -- nvim-treesitter поддерживает разные entrypoints в разных ветках/версиях.
    local ok_configs, ts_configs = pcall(require, "nvim-treesitter.configs")
    if ok_configs and ts_configs and type(ts_configs.setup) == "function" then
        ts_configs.setup(opts)
        return true
    end

    local ok_main, ts_main = pcall(require, "nvim-treesitter")
    if ok_main and ts_main and type(ts_main.setup) == "function" then
        ts_main.setup(opts)
        return true
    end

    return false
end

if not setup_treesitter() then
    vim.api.nvim_create_autocmd("User", {
        pattern = "PackChanged",
        once = true,
        callback = function()
            pcall(vim.cmd, "packadd nvim-treesitter")
            setup_treesitter()
        end,
    })
end

-- HTTP/REST: парсер `kulala_http` ставит и регистрирует Kulala; vim.schedule даёт успеть инициализации.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_kulala_http", { clear = true }),
    pattern = { "http", "rest" },
    callback = function(args)
        vim.schedule(function() pcall(vim.treesitter.start, args.buf) end)
    end,
})

-- Go: явный старт парсеров как fallback, если модульный setup недоступен/отложен.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_go_start", { clear = true }),
    pattern = { "go", "gomod", "gosum", "gowork", "gotmpl" },
    callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})

-- SQL: старт парсера для dadbod и sql файлов.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_sql_start", { clear = true }),
    pattern = { "sql", "mysql", "postgres" },
    callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})
