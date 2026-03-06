return {
    "mfussenegger/nvim-lint",
    config = function()
        require("lint").linters_by_ft = {
            make = { "checkmake" },
            -- см. список встроенных линтеров в nvim-lint:
            -- для golangci-lint используется имя "golangcilint"
            go = { "golangcilint" },
        }

        vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
            callback = function()
                require("lint").try_lint()
            end,
        })
    end,
}
