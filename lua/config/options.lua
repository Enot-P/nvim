vim.opt.number = true             -- Отображает номер строки
vim.opt.cursorline = true         -- Подсветка текущей строки
vim.opt.relativenumber = true     -- Номерация идет относительно строки
vim.opt.clipboard = "unnamedplus" -- Синхронизация для копирования
vim.opt.autowrite = true          -- автосохранение при переключении буферов
vim.opt.autowriteall = true       -- автосохранение при выходе
vim.opt.inccommand =
"split"                           -- включает предварительный просмотр изменений в реальном времени для команд вроде поиска (/) или замены (:s)
vim.opt.splitright = true         -- открывать новый буффер справа при vsplit
vim.opt.splitbelow = true         -- открывать новый буффер снизу при hsplit
vim.opt.isfname:append("@-@")     -- позволяет Vim воспринимать строки вроде "user@-@domain" как единое имя файла
vim.opt.mouse = "a"               -- Поддержка мыши во всех режимах
vim.opt.smoothscroll = true       -- Улучшение скролла
vim.opt.scrolloff = 8             -- Для улучшения скролла
vim.wo.foldlevel = 99             -- Всё будет раскрыто при открытии

vim.opt.swapfile = false          -- Теперь не будет свапфайлов, которые создаются в период изменения файла до его сохраннения
-- vim.opt.updatetime = 50 -- Быстрая время обновы для автокомплитов и т.д.

-- Настройка отступов
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true   -- Все табы превращаются в пробелы
vim.opt.smartindent = true -- умный indent при переносе строк
vim.opt.smarttab = true    -- Если нажать на пробел в начале строки, то вставится табуляция для переноса строк согласно синтаксису
vim.opt.cindent = true     -- Табы будут вставляться в C-lang стиле
vim.opt.wrap = false

-- Позволит сохранить undo буффер между сессиями
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.o.exrc = true -- Разрешает использование локальных файлов .vimrc в директориях проектов