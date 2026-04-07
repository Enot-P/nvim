vim.lsp.enable({ "lua_ls" }) -- "gopls" - пока убрал

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Красивые бордеры для hover и signature (современно)
vim.keymap.set("n", "K", function()
  vim.lsp.buf.hover({ border = "rounded" })
end, { desc = "Hover" })

vim.keymap.set("n", "<C-k>", function()
  vim.lsp.buf.signature_help({ border = "rounded" })
end, { desc = "Signature help" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("gd", vim.lsp.buf.definition, "Goto Definition")
    map("gr", vim.lsp.buf.references, "Goto References")
    map("gI", vim.lsp.buf.implementation, "Goto Implementation")
    map("gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("<leader>gj", vim.diagnostic.open_float, "Open Diagnostic Float")
    map("[d", function()
      vim.diagnostic.jump({ count = -1 })
    end, "Previous Diagnostic")
    map("]d", function()
      vim.diagnostic.jump({ count = 1 })
    end, "Next Diagnostic")
    map("<leader>qd", vim.diagnostic.setqflist, "Open Diagnostic Quickfix")

    -- Format and Save
    vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { buffer = event.buf, desc = "Save" })
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = event.buf,
      callback = function()
        vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
      end,
    })
  end,
})
