return {
    name = "make-ls",
    cmd = { "make-ls" },
    root_dir = vim.fs.root(0, { "Makefile", "makefile", "GNUmakefile" }),
}
