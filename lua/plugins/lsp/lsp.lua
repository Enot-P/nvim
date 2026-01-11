return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",
            "j-hui/fidget.nvim",
        },
        config = function()
            -- LSP keymaps
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    map("gd", vim.lsp.buf.definition, "Goto Definition")
                    map("gr", vim.lsp.buf.references, "Goto References")
                    map("gI", vim.lsp.buf.implementation, "Goto Implementation")
                    map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
                    map("<leader>rn", vim.lsp.buf.rename, "Rename")
                    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("K", vim.lsp.buf.hover, "Hover Documentation")
                    map("gD", vim.lsp.buf.declaration, "Goto Declaration")

                    vim.keymap.set("n", "<C-s>", function()
                        require("conform").format({
                            lsp_fallback = true, -- Если нет форматера в conform, попробует LSP
                            async = false,
                            timeout_ms = 1000,
                        })
                        vim.cmd("w") -- Сохраняем файл
                    end, { desc = "Format and Save" })
                    map("<leader>d", vim.diagnostic.open_float, "Open Diagnostic Float")
                    map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
                    map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
                    map("<leader>q", vim.diagnostic.setqflist, "Open Diagnostic Quickfix")
                end,
            })

            require("fidget").setup({})
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = { callSnippet = "Replace" },
                            diagnostics = { disable = { "missing-fields" } },
                        },
                    },
                },
                yamlls = {},
                jsonls = {},
                lemminx = {},
                marksman = {},
                kotlin_language_server = {},
                groovyls = {},
                dockerls = {},
                bashls = {},
                html = {},
                cssls = {},
                taplo = {},
                -- sqls = {},
                pylsp = {},
            }
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(servers),
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = capabilities
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            })
        end,
    },
}
