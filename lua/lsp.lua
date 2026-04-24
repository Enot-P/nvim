vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("gopls")
vim.lsp.enable("postgres_lsp")

vim.diagnostic.config({
    virtual_text = {
        severity = vim.diagnostic.severity.ERROR,
    },
})

-- utils
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local clients = vim.lsp.get_clients({ bufnr = args.buf })
        local client = clients[1]
        local opts = { buffer = args.buf }

        if client and client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf })
                end,
            })
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
        vim.keymap.set("n", "<leader>cl", function()
            vim.lsp.codelens.display({}, { bufnr = args.buf })
        end, opts)

        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
        end, opts)

        vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
        end, opts)

        vim.keymap.set("n", "<leader>q", function()
            vim.diagnostic.setqflist()
            vim.cmd("copen")
        end, opts)

        if client and client:supports_method("textDocument/codeLens") then
            vim.lsp.codelens.enable(true, { bufnr = args.buf })
        end
    end,
})
