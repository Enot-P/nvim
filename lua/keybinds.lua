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
