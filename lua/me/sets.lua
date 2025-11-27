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
vim.opt.iskeyword:remove("_") -- Разбиваем snake_case на слова для w/e/b

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.g.netrw_keepj = ""
vim.g.netrw_fastbrowse = 2

vim.opt.splitright = true

vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<C-n>", vim.cmd.Ex, { desc = "Открыть проводник" })
vim.opt.colorcolumn = ""

vim.opt.autowrite = true    -- автосохранение при переключении буферов
vim.opt.autowriteall = true -- автосохранение при выходе

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
      vim.cmd("silent! w")
    end
  end,
  desc = "Auto save file on leave",
})
