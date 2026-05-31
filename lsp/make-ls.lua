return {
    name = "make-ls",
    cmd = { "make-ls" },
    filetypes = { "make" },
    root_dir = vim.fs.root(0, { "Makefile", "makefile", "GNUmakefile" }),
}
