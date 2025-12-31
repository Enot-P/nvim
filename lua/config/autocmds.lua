-- Визуально моргнет при копировании
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Более удобная работа в markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.keymap.set("n", "k", "gk")
    vim.keymap.set("n", "j", "gj")
  end,
})

-- Выключает подсветку курсора, когда покидаешь окно
vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  callback = function()
    vim.wo.cursorline = false
  end,
})

-- Открывает help файлы вертикально справа
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "*.txt" },
  callback = function()
    if vim.bo.filetype == "help" then
      vim.cmd.wincmd("")
    end
  end,
})

-- -- Перносить на другую строку если больше 80 символов
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
--   callback = function()
--     vim.opt_local.textwidth = 80
--     vim.opt_local.formatoptions:append("t") -- wrap text
--     vim.opt_local.smartindent = false
--   end,
-- })
