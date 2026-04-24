vim.lsp.enable("pyright")
vim.lsp.enable("gopls")

vim.diagnostic.config({
  virtual_text = true,  -- текст справа
})

-- utils
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)
    vim.lsp.codelens.refresh()
  end,
})

vim.lsp.codelens.refresh()
