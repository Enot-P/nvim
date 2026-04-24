return {
  cmd = { "postgres-language-server", "lsp-proxy" },
  filetypes = { "sql" },
  root_markers = { ".git" },
  on_init = function(client)
    print("postgres_lsp initialized")
  end,
}
