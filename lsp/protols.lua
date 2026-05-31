return {
    name = "protols",
    cmd = { "protols" },
    filetypes = { "proto" },
    root_dir = function(fname) return vim.fs.root(fname, { ".proto", ".git", "protols.toml", "buf.yaml" }) end,
}
