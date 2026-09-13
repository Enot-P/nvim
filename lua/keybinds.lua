local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = "."

-- Перемещение строк в визуальном режиме
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

-- отцентровка экрана при перемещении по файлу
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Смещение не сбрасывает визуальный режим более
vim.keymap.set("x", "<", "<gv", opts)
vim.keymap.set("x", ">", ">gv", opts)

vim.keymap.set("x", "p", '"_dP', opts) -- При вставке буффер обмена не заменяется
vim.keymap.set({ "x" }, "<leader>d", [["_d]]) -- Удаление без вставки в буффео обмена
vim.keymap.set("n", "x", '"_x', opts) -- Посимвольное удаление также ничего не делает

-- глобальная замена слова под курсором (в рамках файла)
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { desc = "Replace word under cursor" })

vim.keymap.set({ "i" }, "<C-c>", "<Esc>") -- Универсальный выход из любых режимов
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true }) -- Уберет выделения, которые идут при приске через /

-- split комманды
-- vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
-- vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
-- vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Перемещение по split окнам
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move left" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move up" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move right" })

-- Размер окон
vim.keymap.set("n", "<M-l>", "<cmd>vertical resize -6<CR>", { desc = "Resize right" })
vim.keymap.set("n", "<M-k>", "<cmd>resize -3<CR>", { desc = "Resize up" })
vim.keymap.set("n", "<M-j>", "<cmd>resize +3<CR>", { desc = "Resize down" })
vim.keymap.set("n", "<M-h>", "<cmd>vertical resize +6<CR>", { desc = "Resize left" })

-- Buffer команды
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprev<cr>", { desc = "prev buffer" })
vim.keymap.set("n", "<leader>bx", "<cmd>bdelete<cr>", { desc = "remove buffer" })

-- Сохранение по Ctrl+S во всех режимах (:update — сохраняет только при изменениях)
vim.keymap.set("n", "<C-s>", ":update<CR>", { silent = true, desc = "Сохранить файл" })
vim.keymap.set(
    "i",
    "<C-s>",
    "<Esc>:update<CR>a",
    { silent = true, desc = "Сохранить и вернуться в insert" }
)
vim.keymap.set(
    "v",
    "<C-s>",
    "<Esc>:update<CR>gv",
    { silent = true, desc = "Сохранить и сохранить выделение" }
)

vim.keymap.set("n", "<C-Return>", "o<Esc>", { desc = "Новая строка снизу" })
vim.keymap.set("n", "<C-;>", "A;<Esc>", { desc = "Точка с запятой в конце" })

-- ── dS -- развернуть блок: убрать строку-заголовок и строку с `}` ─────────────
-- Продолжение семейства nvim-surround: ySS{ оборачивает в блок, dS разворачивает
-- его обратно. В нативном vim `d` + `S` -- no-op (S не motion), так что маппинг
-- ничего не перекрывает и не добавляет ожидания к dd/dw.
--
-- Курсор -- в любом месте блока. Тело сдвигается на один уровень влево тем же
-- whitespace, который уже лежит в файле: ни indentexpr, ни форматтер не
-- вмешиваются, и табы от gofmt не превращаются в пробелы из-за expandtab.
local function unwrap_block()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    -- хвостовой комментарий не должен мешать увидеть открывающую скобку
    local bare = line:gsub("%s*//.*$", ""):gsub("%s*%-%-.*$", "")

    local open_row, open_col
    local brace = bare:match("^.*()%{%s*$")
    if brace then
        open_row, open_col = row, brace - 1
    else
        -- ближайшая незакрытая `{` выше курсора
        local pos = vim.fn.searchpairpos("{", "", "}", "bnW")
        if pos[1] == 0 then
            return vim.notify("dS: вокруг курсора нет блока", vim.log.levels.WARN)
        end
        open_row, open_col = pos[1], pos[2] - 1
    end

    -- парную `}` searchpairpos ищет от курсора, поэтому встаём на `{`
    local save = { row, col }
    vim.api.nvim_win_set_cursor(0, { open_row, open_col })
    local close_row = vim.fn.searchpairpos("{", "", "}", "nW")[1]
    vim.api.nvim_win_set_cursor(0, save)

    if close_row == 0 then
        return vim.notify("dS: не нашёл парную `}`", vim.log.levels.WARN)
    end
    if close_row == open_row then
        return vim.notify("dS: блок в одну строку", vim.log.levels.WARN)
    end

    local head = vim.api.nvim_buf_get_lines(0, open_row - 1, open_row, false)[1]
    local tail = vim.api.nvim_buf_get_lines(0, close_row - 1, close_row, false)[1]
    -- на строке с `}` не должно висеть кода: иначе удаление строки его съест.
    -- Хвост вызова разрешён -- это закрытие замыкания: `}()`, `}(ch)`.
    if not (tail:match("^%s*%}[%s,;%)]*$") or tail:match("^%s*%}%s*%b()[%s,;]*$")) then
        return vim.notify("dS: на строке с `}` есть код", vim.log.levels.WARN)
    end

    -- сдвиг тела: сколько ведущего whitespace уйдёт с каждой строки
    local body = vim.api.nvim_buf_get_lines(0, open_row, close_row - 1, false)
    local min_ws
    for _, l in ipairs(body) do
        local ws = l:match("^%s*")
        if l:match("%S") and (not min_ws or #ws < #min_ws) then
            min_ws = ws
        end
    end
    local strip = min_ws and math.max(#min_ws - #head:match("^%s*"), 0) or 0
    for i, l in ipairs(body) do
        if l:match("%S") then
            body[i] = l:sub(strip + 1)
        end
    end

    -- одной правкой: заголовок + тело + `}` -> сдвинутое тело (один undo)
    vim.api.nvim_buf_set_lines(0, open_row - 1, close_row, false, body)

    local target = #body > 0 and math.min(math.max(row - 1, open_row), open_row + #body - 1)
        or math.max(open_row - 1, 1)
    vim.api.nvim_win_set_cursor(0, { target, 0 })
    vim.cmd("normal! ^")
end

vim.keymap.set(
    "n",
    "dS",
    unwrap_block,
    { desc = "Развернуть блок (убрать `{` и `}` со строками)" }
)

vim.keymap.set(
    "n",
    "gl",
    function()
        vim.diagnostic.open_float(nil, {
            scope = "line",
            focus = false,
            close_events = {
                "CursorMoved",
                "CursorMovedI",
                "BufHidden",
                "BufLeave",
                "InsertEnter",
            },
        })
    end,
    { desc = "Show line diagnostic" }
)

-- Удаляю gc
vim.keymap.del({ "n", "x", "o" }, "gc")

-- ── Select mode не должен перехватывать печатные символы ──────────────────────
-- Маппинги, заданные через :map/:noremap без указания режима, попадают ещё и в
-- select mode. А там любой печатный символ обязан заменять выделение -- именно в
-- этом режиме сидит плейсхолдер сниппета. Вместо замены срабатывает команда, и
-- буква не печатается.
--
-- Так ломались [[ ][ [] ]] из штатного ftplugin/go.vim, gta и S в sql, плюс
-- несколько десятков глобальных от плагинов -- на e, o, a, f, g, R и других
-- обычных буквах. Свои маппинги (p, J, K, <, >, gc*) переведены на "x" выше,
-- но чужие так не поправить, поэтому снимаем select-вариант при входе в режим.
--
-- Всё, что начинается со спецклавиши, остаётся: <Tab>, <S-Tab>, <Plug>... нужны
-- самим сниппетам. Остальные режимы маппинга не затрагиваются -- удаление
-- select-варианта не трогает n/x/o.
local function strip_select_mode()
    local function strip(maps, opts)
        for _, m in ipairs(maps) do
            if m.lhs:sub(1, 1) ~= "<" then
                pcall(vim.keymap.del, "s", m.lhs, opts)
            end
        end
    end
    strip(vim.api.nvim_get_keymap("s"), {})
    local buf = vim.api.nvim_get_current_buf()
    strip(vim.api.nvim_buf_get_keymap(buf, "s"), { buffer = buf })
end

vim.api.nvim_create_autocmd("ModeChanged", {
    group = vim.api.nvim_create_augroup("strip_select_mode", { clear = true }),
    pattern = "*",
    desc = "Снять маппинги на печатных символах в select mode",
    callback = function()
        -- s, S и <C-S> -- три разновидности select mode
        if vim.fn.mode():match("^[sS\19]") then
            strip_select_mode()
        end
    end,
})
