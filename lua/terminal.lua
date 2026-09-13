-- Работа в терминальном режиме.
--
-- Основная проблема: попав в терминальный режим, из него нечем выйти -- нужен
-- неочевидный <C-\><C-n>. Ниже два выхода: <C-q> работает везде, <Esc><Esc> --
-- только там, где Esc не нужен самой программе.

-- TUI, которым Esc принадлежит по праву: у lazygit на нём навигация,
-- у Claude Code двойной Esc правит предыдущее сообщение. Плюс глобальный
-- <Esc><Esc> добавил бы им timeoutlen (300ms) задержки на каждый одиночный Esc.
-- Опознаём по имени команды; filetype -- запасной путь для TUI-плагинов,
-- которые метят свой терминальный буфер (был yazi, заменён на oil -- он не терминал).
local tui_filetypes = {}
local tui_commands = { "claude", "lazygit", "lazydocker", "gitui", "fzf", "htop", "btop" }

local function is_tui(buf)
    if tui_filetypes[vim.bo[buf].filetype] then
        return true
    end
    -- имя терминального буфера содержит команду: term://~/dir//PID:/usr/bin/lazygit
    local name = vim.api.nvim_buf_get_name(buf)
    for _, cmd in ipairs(tui_commands) do
        if name:find(cmd, 1, true) then
            return true
        end
    end
    return false
end

-- Универсальный выход: одна клавиша, одинаково во всех терминалах, ничего
-- не перехватывает у TUI и не тормозит Esc.
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>", { desc = "Выйти из терминального режима" })

-- Уйти из терминала в соседнее окно одним нажатием: программа внутри продолжает
-- работать (Claude не прерывается, в отличие от <C-c>), а курсор оказывается в коде.
-- Те же <C-h/j/k/l>, что и в normal mode (keybinds.lua), просто с выходом из term-режима.
for key, dir in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
    vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><C-w>" .. dir, { desc = "В окно: " .. dir })
end

-- Привычный <Esc><Esc> -- по умолчанию для всех, кроме TUI (см. TermOpen ниже).
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Выйти из терминального режима" })

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("enot_terminal", { clear = true }),
    callback = function(args)
        local buf = args.buf

        -- терминалу номера строк и колонка знаков только мешают
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.scrolloff = 0

        if is_tui(buf) then
            -- буферный маппинг перекрывает глобальный: Esc уходит в программу,
            -- выйти в normal mode всё ещё можно через <C-q>
            vim.keymap.set("t", "<Esc><Esc>", "<Esc><Esc>", { buffer = buf })

            -- fzf двигает выбор по <C-j>/<C-k> -- ему они нужнее, чем прыжок по окнам.
            if vim.api.nvim_buf_get_name(buf):find("fzf", 1, true) then
                vim.keymap.set("t", "<C-j>", "<C-j>", { buffer = buf })
                vim.keymap.set("t", "<C-k>", "<C-k>", { buffer = buf })
            end

            return
        end

        -- snacks-терминалы уже умеют q = hide (snacs.lua), их toggle ломать нельзя.
        -- Обычному `:terminal` (gor/got/gof) такого нет -- закрываем по q, как во флоате.
        if vim.bo[buf].filetype ~= "snacks_terminal" then
            vim.keymap.set("n", "q", function()
                vim.api.nvim_buf_delete(buf, { force = true })
            end, { buffer = buf, nowait = true, desc = "Закрыть терминал" })
        end
    end,
})
