-- netrw отключаем до его загрузки: директории открывает oil (default_file_explorer).
-- Сам oil гасит netrw в своём setup(), но к тому моменту тот уже успевает навесить
-- автокоманды на BufEnter директории -- дешевле не давать ему загрузиться вовсе.
vim.g.loaded_netrwPlugin = 1

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

local oil = require("oil")

-- Директория, которую сейчас показывает oil-буфер. Нужна действиям, работающим
-- «по текущему каталогу» (grep, замена): сам oil им ничего не передаёт.
local function oil_dir()
    return oil.get_current_dir(0) or vim.uv.cwd()
end

-- Аналоги <c-s>/<c-g> из yazi: искать и заменять, не выходя из файлового менеджера.
local function grep_in_dir()
    require("snacks").picker.grep({ dirs = { oil_dir() } })
end

local function replace_in_dir()
    require("grug-far").open({ prefills = { paths = oil_dir() } })
end

oil.setup({
    default_file_explorer = true,
    columns = { "icon" },
    -- `d` в oil -- это удаление строки в буфере, то есть файла на диске. Корзина
    -- (freedesktop) делает такую правку обратимой -- как `d` в yazi.
    delete_to_trash = true,
    -- Подтверждение остаётся на всё нетривиальное (перемещения, массовые удаления),
    -- но переименовать один файл, не отвечая на попап, удобнее.
    skip_confirm_for_simple_edits = true,
    -- Правки на диске мимо nvim (git checkout, соседний терминал) подтягиваются сами.
    watch_for_changes = true,
    view_options = {
        -- Дотфайлы видно сразу: конфиг -- сам сплошной дотфайл, и ходить в него
        -- через `g.` каждый раз незачем. Скрыть обратно -- всё тот же `g.`.
        show_hidden = true,
    },
    -- Флоат поверх кода: каталог -- это заход «посмотреть и вернуться», ради него
    -- незачем перекраивать раскладку окон. Превью oil в таком режиме рисует вторым
    -- флоатом рядом, то есть колонки «каталог | файл» остаются на месте.
    float = {
        padding = 2,
        -- 0 -- это «во весь экран минус padding». Чуть уже: видно, что под окном
        -- остался код, и флоат не притворяется обычной раскладкой.
        max_width = 0.85,
        max_height = 0.85,
        border = "rounded",
        -- Куда отъезжает превью. "auto" смотрит на splitright (у нас true, то есть
        -- тоже вправо), но здесь это не сплит, а вторая плавашка -- пишем явно.
        preview_split = "right",
    },
    preview_win = {
        update_on_cursor_moved = true,
        -- Не грузим файл целиком в настоящий буфер: подсветка есть, а LSP,
        -- автокоманды и прочая машинерия на пролистывание каталога не запускаются.
        preview_method = "fast_scratch",
        disable_preview = function(filename)
            -- Бинарники и всё тяжёлое превьюить смысла нет -- только лаг.
            local size = vim.uv.fs_stat(filename)
            return (size and size.size or 0) > 1024 * 1024
        end,
    },
    confirmation = { border = "rounded" },
    progress = { border = "rounded" },
    ssh = { border = "rounded" },
    keymaps_help = { border = "rounded" },
    keymaps = {
        -- Выход из oil: возвращает буфер, который был в окне до него.
        -- Штатный <c-c> тоже на месте.
        ["q"] = { "actions.close", mode = "n" },
        -- Справка была на <f1> в yazi; штатный g? тоже остаётся.
        ["<F1>"] = { "actions.show_help", mode = "n" },
        ["<C-q>"] = "actions.send_to_qflist",
        ["<C-y>"] = "actions.copy_entry_path",
        -- <c-\> менял cwd в yazi; здесь то же самое (штатные ` и g~ на месте).
        ["<C-\\>"] = { "actions.cd", mode = "n" },
        -- <c-s> в oil занят вертикальным сплитом, поэтому grep уехал на <c-f>.
        ["<C-f>"] = { callback = grep_in_dir, desc = "Grep по этой директории", mode = "n" },
        ["<C-g>"] = { callback = replace_in_dir, desc = "Замена по этой директории", mode = "n" },
    },
})

-- oil про «корень проекта» ничего не знает -- он открывает то, что дали.
-- Корень считаем сами: сначала репозиторий, потом маркеры модуля, в конце -- cwd.
local function project_root()
    local buf_root = vim.fs.root(0, ".git")
        or vim.fs.root(0, { "go.work", "go.mod", "pubspec.yaml", "pyproject.toml", "package.json", "Makefile" })
    return buf_root or vim.uv.cwd()
end

-- У oil есть свой toggle_float, но он не разбирает за собой превью, а у нас оно
-- открыто всегда (автопревью ниже). Поэтому свой: второе нажатие закрывает обе
-- плавашки -- и каталог, и превью.
---@param dir? fun(): string каталог; без него -- каталог текущего файла
local function toggle(dir)
    return function()
        if vim.bo.filetype ~= "oil" then
            return oil.open_float(dir and dir() or nil)
        end
        -- Превью -- отдельное окно, за флоатом оно не закрывается: сначала оно,
        -- иначе на экране останется висеть плавашка с уже закрытым каталогом.
        local preview = require("oil.util").get_preview_win()
        if preview and vim.api.nvim_win_is_valid(preview) then
            vim.api.nvim_win_close(preview, true)
        end
        oil.close()
    end
end

local map = vim.keymap.set

map("n", "<leader>e", toggle(), { desc = "Oil (каталог текущего файла)" })
map("n", "<leader>E", toggle(project_root), { desc = "Oil (корень проекта)" })
map("n", "<leader>ue", toggle(vim.uv.cwd), { desc = "Oil (cwd)" })
-- Идиома oil/vinegar: «на уровень вверх» из файла. Делает то же, что <leader>e --
-- оставлено обеими руками: одна привычка из yazi, вторая из самого oil.
map("n", "-", toggle(), { desc = "Oil (родительский каталог)" })

-- ── Автопревью ────────────────────────────────────────────────────────────────
-- Штатно превью открывается только по <c-p>. Ловим момент, когда oil дорисовал
-- буфер, и открываем сразу -- дальше oil обновляет превью сам, по движению курсора
-- (preview_win.update_on_cursor_moved). Событие OilEnter в доках не описано, но
-- существует с давних пор (lua/oil/view.lua, после рендера буфера); если после
-- обновления плагина превью перестанет открываться -- смотреть надо туда.
vim.api.nvim_create_autocmd("User", {
    pattern = "OilEnter",
    group = vim.api.nvim_create_augroup("enot_oil", { clear = true }),
    callback = function(args)
        if vim.api.nvim_get_current_buf() ~= args.data.buf then
            return -- буфер дорисовался в фоне, окно сейчас не наше
        end
        if vim.wo.previewwindow then
            return -- каталог под курсором рисуется в самом превью -- не рекурсим
        end
        if not oil.get_cursor_entry() then
            return -- пустой каталог: превьюить нечего
        end
        oil.open_preview()
    end,
})
