-- leetcode.nvim -- задачи LeetCode в отдельной вкладке или отдельной сессией.
-- alias `leet` = `nvim leetcode.nvim`, где "leetcode.nvim" не файл, а
-- аргумент-пароль: плагин ловит его на VimEnter и монтирует дашборд.
vim.pack.add({
    -- Уже приходят из ssh.lua, но продублированы, чтобы файл не зависел от
    -- порядка require в plugins/init.lua: vim.pack дедуплицирует по имени.
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",

    -- Без version: последний тег v0.3.1 -- июнь 2025, а main с тех пор унёс
    -- ~700 строк правок (рендер задачи, спиннеры, mini-picker). Ревизию всё
    -- равно держит nvim-pack-lock.json, так что воспроизводимость не теряем --
    -- обновление случается только по явному vim.pack.update().
    { src = "https://github.com/kawre/leetcode.nvim" },
})

require("leetcode").setup({
    -- Должно совпадать с аргументом в alias `leet`.
    arg = "leetcode.nvim",
    lang = "golang",

    -- Автовыбор пошёл бы по списку snacks → fzf-lua → telescope и всё равно
    -- нашёл бы snacks, но telescope тут тоже стоит (для remote-nvim), так что
    -- лучше сказать явно, чем зависеть от порядка резолва.
    picker = { provider = "snacks-picker" },

    plugins = {
        -- Без этого `:Leet` в обычной сессии открывался бы поверх текущего
        -- буфера, а выход из дашборда делал бы безусловный `qa!` -- то есть
        -- выбрасывал несохранённые буферы молча. С ним `:Leet` уходит в свою
        -- вкладку, а stop() всего лишь размонтирует меню и вернёт cwd.
        -- `qa!` остаётся только там, где он и уместен -- в сессии от `leet`.
        non_standalone = true,
    },

    -- Картинки в условиях умеет только image.nvim; у нас snacks.image, так что
    -- оставляем выключенным -- иначе плагин ругается на отсутствующий модуль.
    image_support = false,
})

-- Первый запуск: `:Leet` (или alias `leet`) → Sign In → вставить cookie из
-- DevTools. Дальше `:Leet menu`, `:Leet run`, `:Leet submit`.
