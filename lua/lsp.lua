-- Не поднимаем сервер в буферах, чьё имя не является путём к файлу (diffview://…, fugitive://…):
-- их URI уходит серверу как есть, и gopls отвечает JSON RPC parse error.
-- on_dir(nil) => корень по-прежнему считается из root_markers конкретного сервера.
vim.lsp.config("*", {
    root_dir = function(bufnr, on_dir)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name:match("^%a[%w+.%-]*://") then
            return
        end
        on_dir(nil)
    end,

    -- Neovim по умолчанию не сообщает серверу о поддержке слежения за файлами на
    -- Linux (protocol.lua: dynamicRegistration только для Darwin и Windows) --
    -- считается, что тамошние бэкенды слабые. Из-за этого gopls не узнаёт о правках
    -- go.mod/go.sum со стороны (`go get`, `go mod tidy`) и держит ошибки о
    -- неимпортированном пакете, пока go.mod не откроешь в буфере вручную.
    -- Здесь установлен inotifywait, поэтому nvim берёт нормальный inotify-бэкенд,
    -- а не полинг (см. lsp/_watchfiles.lua) -- включаем.
    capabilities = {
        workspace = {
            didChangeWatchedFiles = { dynamicRegistration = true },
        },
    },
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("gopls")
vim.lsp.enable("golangci_lint_ls")
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

        -- gd здесь не переопределяем: он уже висит глобально на snacks.picker.lsp_definitions
        -- (snacs.lua), рядом с gD/gy/gr. Буферный маппинг перебивал глобальный, из-за чего
        -- в LSP-буферах работал нативный прыжок без пикера, а пикер срабатывал только там,
        -- где LSP нет, — и отвечал "No results found".
        -- K (hover), gri (implementation), grn (rename), gra (code action),
        -- grt (type definition) — из коробки в 0.11+.

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

        -- Inlay hints выключены по умолчанию; включаются вручную через <leader>uh.
    end,
})
