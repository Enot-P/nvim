vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("gopls")
vim.lsp.enable("postgres_lsp")
vim.lsp.enable("protols")
vim.lsp.enable("yamlls")

vim.diagnostic.config({
    virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        spacing = 4,
    },
})

-- utils
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local clients = vim.lsp.get_clients({ bufnr = args.buf })
        local client = clients[1]
        local opts = { buffer = args.buf }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))

        vim.keymap.set(
            "n",
            "gi",
            vim.lsp.buf.implementation,
            vim.tbl_extend("force", opts, { desc = "Go to implementation" })
        )

        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))

        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

        vim.keymap.set(
            "n",
            "<leader>ca",
            vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, { desc = "Code actions" })
        )

        vim.keymap.set(
            "n",
            "<leader>cl",
            function() vim.lsp.codelens.run({}) end,
            vim.tbl_extend("force", opts, { desc = "Run code lens" })
        )

        vim.keymap.set(
            "n",
            "<leader>d",
            vim.diagnostic.open_float,
            vim.tbl_extend("force", opts, { desc = "Show diagnostics" })
        )

        vim.keymap.set(
            "n",
            "[d",
            function() vim.diagnostic.jump({ count = -1 }) end,
            vim.tbl_extend("force", opts, { desc = "Previous diagnostic" })
        )

        vim.keymap.set(
            "n",
            "]d",
            function() vim.diagnostic.jump({ count = 1 }) end,
            vim.tbl_extend("force", opts, { desc = "Next diagnostic" })
        )

        vim.keymap.set("n", "<leader>q", function()
            vim.diagnostic.setqflist()
            vim.cmd("copen")
        end, vim.tbl_extend("force", opts, { desc = "Diagnostics to quickfix" }))

        if client and client:supports_method("textDocument/codeLens") then
            vim.lsp.codelens.enable(true, { bufnr = args.buf })
        end
    end,
})
