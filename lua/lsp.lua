vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("gopls")
vim.lsp.enable("postgres_lsp")
vim.lsp.enable("protols")
vim.lsp.enable("yamlls")
vim.lsp.enable("make-ls")

vim.diagnostic.config({
    virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        spacing = 4,
    },
})

local orig_rename = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
    orig_rename(err, result, ctx, config)
    vim.cmd("silent! wall")
end
-- utils
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local clients = vim.lsp.get_clients({ bufnr = args.buf })
        local client = clients[1]
        local opts = { buffer = args.buf }

        -- gd оставляем кастомным (нативного дефолта нет).
        -- K (hover), gri (implementation), grn (rename), gra (code action) — из коробки в 0.11.
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))

        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

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

        -- [d / ]d (переход по диагностикам) — нативные дефолты с 0.10.

        vim.keymap.set("n", "<leader>q", function()
            vim.diagnostic.setqflist()
            vim.cmd("copen")
        end, vim.tbl_extend("force", opts, { desc = "Diagnostics to quickfix" }))

        if client and client:supports_method("textDocument/codeLens") then
            vim.lsp.codelens.enable(true, { bufnr = args.buf })
        end

        if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
    end,
})
