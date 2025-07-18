vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.errorbells = false
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.g.netrw_keepj = ""
vim.g.netrw_fastbrowse = 2

vim.opt.splitright = true

vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<C-n>", vim.cmd.Ex)
vim.opt.colorcolumn = ""
    vim.keymap.set('n', '<leader>fr', ':FlutterRunTmux<CR>', { desc = 'Flutter Run in Tmux' })
    vim.keymap.set('n', '<leader>frl', ':FlutterReloadTmux<CR>', { desc = 'Flutter Reload' })
    vim.keymap.set('n', '<leader>frs', ':FlutterRestartTmux<CR>', { desc = 'Flutter Restart' })
    vim.keymap.set('n', '<leader>fq', ':FlutterQuitTmux<CR>', { desc = 'Flutter Quit' })
    vim.keymap.set('n', '<leader>fd', ':FlutterDevices<CR>', { desc = 'Flutter Devices' })
    vim.keymap.set('n', '<leader>fe', ':FlutterEmulators<CR>', { desc = 'Flutter Emulators' })
