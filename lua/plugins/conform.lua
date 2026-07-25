vim.pack.add({
    { src = "https://github.com/stevearc/conform.nvim" },
})

require("conform").setup({
    formatters_by_ft = {
        sql = { "sql_formatter" },
        go = { "goimports", "gofmt" },
        python = { "ruff_format" },
        lua = { "stylua" },
    },

    format_on_save = function(bufnr)
        -- Не форматировать конфиги caelestia: stylua переформатирует апстримные
        -- файлы и ломает `git pull --autostash` конфликтами по пробелам
        -- ~/.config/hypr — симлинк в репо, поэтому проверяем и сырой, и разрешённый путь
        local name = vim.api.nvim_buf_get_name(bufnr)
        for _, p in ipairs({ name, vim.fn.resolve(name) }) do
            if p:find(vim.fn.expand("~/.local/share/caelestia"), 1, true) or p:find(vim.fn.expand("~/.config/hypr"), 1, true) then
                return false
            end
        end
        if vim.bo[bufnr].filetype == "sql" then
            return { timeout_ms = 1000, lsp_format = "never" }
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
    end,

    formatters = {
        stylua = {
            prepend_args = { "--config-path", vim.fn.stdpath("config") .. "/stylua.toml" },
        },
        sql_formatter = {
            command = "sql-formatter",
            args = {
                "-c",
                vim.fn.stdpath("config") .. "/.sql-formatter.json",
            },
        },
    },
})
