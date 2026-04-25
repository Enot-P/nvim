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
            command = "npx",
            args = {
                "sql-formatter",
                "-c",
                vim.fn.stdpath("config") .. "/.sql-formatter.json",
            },
        },
    },
})
