-- codewars.nvim -- решать ката, не уходя в браузер. Живёт в отдельной сессии:
-- alias `cw` = `nvim codewars.nvim`, где "codewars.nvim" -- не файл, а
-- аргумент-пароль: плагин ловит его на VimEnter и монтирует дашборд.
--
-- В обычный nvim не грузится вовсе, и дело не в скорости старта. Пункт Exit в
-- дашборде и `:CW exit` вызывают безусловный `vim.cmd("qa!")` -- с
-- восклицательным знаком, то есть несохранённые буферы выбрасываются молча.
-- Проверка на standalone у автора есть, но только в автокоманде QuitPre, не на
-- этом пути. Нет команды `:CW` в рабочей сессии -- нет и этого способа потерять
-- правки. Нужен `:CW` везде -- убрать этот if.
if vim.fn.argc(-1) ~= 1 or vim.fn.argv(0, -1) ~= "codewars.nvim" then
    return
end

vim.pack.add({
    -- Те же три уже тянет ssh.lua, но полагаться на порядок require в
    -- plugins/init.lua незачем: vim.pack дедуплицирует по имени.
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",

    {
        src = "https://github.com/prosk-sudo/codewars.nvim",
        -- Прогон тестов, submit и публикация идут через неофициальные эндпоинты
        -- codewars.com с браузерной кукой, так что main ломается чаще среднего.
        -- Держимся последнего тега ветки 0.3.x, а не вершины main.
        version = vim.version.range("0.3"),
    },
})

require("codewars").setup({
    -- Должно совпадать с аргументом в alias `cw`, иначе дашборд не поднимется.
    arg = "codewars.nvim",
    lang = "go",
})

-- Первый запуск: `:CW cookie` -- вставить CSRF-TOKEN и _session_id из DevTools.
-- Кука ляжет в ~/.cache/nvim/codewars/cookie обычным файлом по umask.
-- `:CW doctor` покажет версии, авторизацию и не поехала ли вёрстка сайта.
