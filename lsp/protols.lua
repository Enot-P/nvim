return {
    name = "protols",
    cmd = { "protols" },
    filetypes = { "proto" },
    root_dir = vim.fs.root(0, { ".proto", ".git", "protols.toml", "buf.yaml" }),
}
