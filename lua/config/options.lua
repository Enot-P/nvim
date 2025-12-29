vim.opt.number = true -- Отображает номер строки
vim.opt.cursorline = true -- Подсветка текущей строки
vim.opt.relativenumber = true -- Номерация идет относительно строки
vim.opt.clipboard = "unnamedplus" -- Синхронизация для копирования
vim.opt.autowrite = true -- автосохранение при переключении буферов
vim.opt.autowriteall = true -- автосохранение при выходе
vim.opt.inccommand = "split" -- включает предварительный просмотр изменений в реальном времени для команд вроде поиска (/) или замены (:s)
vim.opt.splitright = true -- открывать новый буффер справа при vsplit
vim.opt.splitbelow = true -- открывать новый буффер снизу при hsplit
vim.opt.isfname:append("@-@") -- позволяет Vim воспринимать строки вроде "user@-@domain" как единое имя файла
vim.opt.mouse = "a" -- Поддержка мыши во всех режимах
vim.opt.scrolloff = 8 -- Для улучшения скролла

-- Настройка отступов
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- Перносить на другую строку если больше 80 символов
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.formatoptions:append("t") -- wrap text
    vim.opt_local.smartindent = false
  end,
})

-- Позволит сохранить undo буффер между сессиями
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
