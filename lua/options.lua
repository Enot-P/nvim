-- ============================================================================
-- UI / ОТОБРАЖЕНИЕ
-- ============================================================================

vim.opt.number = true -- абсолютные номера строк
vim.opt.relativenumber = true -- относительные номера
vim.opt.cursorline = true -- подсветка текущей строки
vim.opt.wrap = false -- не переносить длинные строки

vim.opt.scrolloff = 8 -- отступ сверху/снизу при скролле
vim.opt.sidescrolloff = 10 -- отступ слева/справа

vim.opt.signcolumn = "yes" -- всегда показывать колонку знаков (LSP/git)
vim.opt.colorcolumn = "100" -- вертикальная линия на 100 символах
vim.opt.showmatch = true -- подсветка парных скобок

vim.opt.cmdheight = 1 -- высота командной строки
vim.opt.pumheight = 10 -- высота popup меню
vim.opt.pumblend = 10 -- прозрачность popup
vim.opt.winblend = 0 -- прозрачность floating окон

vim.opt.showmode = false -- режим не показывается (для statusline)

vim.opt.fillchars = { eob = " " } -- убрать ~ на пустых строках

-- ============================================================================
-- СКРОЛЛ / МЫШЬ
-- ============================================================================

vim.opt.mouse = "a" -- мышь во всех режимах
vim.opt.smoothscroll = true -- плавный скролл (у тебя было)

-- ============================================================================
-- ОТСТУПЫ / ТАБЫ
-- ============================================================================

vim.opt.tabstop = 4 -- ширина таба
vim.opt.shiftwidth = 4 -- ширина отступа
vim.opt.softtabstop = 4 -- поведение Tab/Backspace
vim.opt.expandtab = true -- табы = пробелы

vim.opt.smartindent = true -- умный авто-отступ
vim.opt.autoindent = true -- копировать отступ строки
vim.opt.smarttab = true -- Tab в начале строки умный
vim.opt.cindent = true -- C-style отступы

-- ============================================================================
-- ПОИСК
-- ============================================================================

vim.opt.ignorecase = true -- поиск без учета регистра
vim.opt.smartcase = true -- если есть заглавные — учитывать регистр
vim.opt.hlsearch = true -- подсветка результатов
vim.opt.incsearch = true -- поиск "на лету"

-- ============================================================================
-- ФАЙЛЫ / СОХРАНЕНИЕ
-- ============================================================================

vim.opt.swapfile = false -- отключить swap файлы
vim.opt.backup = false -- отключить backup
vim.opt.writebackup = false -- не создавать backup при записи

vim.opt.undofile = true -- сохранять undo между сессиями
vim.opt.undodir = vim.fn.expand("~/.vim/undodir") -- папка undo

vim.opt.autowrite = true -- автосохранение при переключении
vim.opt.autowriteall = true -- автосохранение при выходе
vim.opt.autoread = true -- перечитывать файл при изменении извне

vim.opt.updatetime = 300 -- задержка для CursorHold/LSP
vim.opt.timeoutlen = 300 -- таймаут для маппингов
vim.opt.ttimeoutlen = 0 -- быстрые keycode события

-- создать папку для undo если нет
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

-- ============================================================================
-- БУФЕРЫ / ПОВЕДЕНИЕ
-- ============================================================================

vim.opt.hidden = true -- можно скрывать буферы без сохранения
vim.opt.errorbells = false -- отключить звуки ошибок

vim.opt.backspace = "indent,eol,start" -- нормальный backspace
vim.opt.autochdir = false -- не менять cwd автоматически

vim.opt.iskeyword:append("-") -- считать - частью слова
vim.opt.path:append("**") -- поиск по подпапкам

vim.opt.selection = "inclusive" -- выделение включает последний символ

vim.opt.clipboard = "unnamedplus"
vim.opt.modifiable = true -- буфер можно редактировать
vim.opt.encoding = "utf-8" -- кодировка

-- ============================================================================
-- SPLIT / ОКНА
-- ============================================================================

vim.opt.splitright = true -- vsplit вправо
vim.opt.splitbelow = true -- split вниз

-- ============================================================================
-- COMPLETION
-- ============================================================================

vim.opt.completeopt = "menuone,noinsert,noselect" -- поведение автокомплита
vim.opt.wildmenu = true -- улучшенный cmd completion
vim.opt.wildmode = "longest:full,full" -- логика Tab completion

-- ============================================================================
-- FOLDING (treesitter)
-- ============================================================================

vim.opt.foldmethod = "expr" -- folding через выражение
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- treesitter folding
vim.opt.foldlevel = 99 -- всё раскрыто по умолчанию

-- ============================================================================
-- ПРОИЗВОДИТЕЛЬНОСТЬ
-- ============================================================================

vim.opt.lazyredraw = true -- не перерисовывать при макросах
vim.opt.synmaxcol = 300 -- лимит подсветки строк
vim.opt.redrawtime = 10000 -- время на рендер
vim.opt.maxmempattern = 20000 -- лимит regex памяти

-- ============================================================================
-- ДОПОЛНИТЕЛЬНО
-- ============================================================================

vim.opt.inccommand = "split" -- предпросмотр замены
vim.opt.diffopt:append("linematch:60") -- улучшенный diff

vim.o.exrc = true -- локальные .nvim.lua

vim.opt.autoread = true -- Neovim перечитывает буфер при внешнем изменении
