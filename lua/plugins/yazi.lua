-- netrw отключаем до его загрузки: директории открывает yazi (open_for_directories).
vim.g.loaded_netrwPlugin = 1

vim.pack.add({ "https://github.com/mikavilpas/yazi.nvim" })

-- ── Своё окно помощи ──────────────────────────────────────────────────────────
-- Штатное (show_help) позиционируется через bufpos относительно терминального
-- буфера yazi и уезжает за правый край экрана. Рисуем своё, по центру редактора.
local help_lines = {
    " yazi.nvim ",
    "",
    " `<cr>`      открыть файл",
    " `<c-v>`     открыть в вертикальном сплите",
    " `<c-x>`     открыть в горизонтальном сплите",
    " `<c-t>`     открыть во вкладке",
    " `<c-o>`     открыть и выбрать окно",
    " `<c-q>`     отправить в quickfix",
    " `<c-s>`     grep по директории/выделенным (snacks)",
    " `<c-g>`     замена по директории/выделенным (grug-far)",
    " `<c-y>`     скопировать относительные пути",
    " `<c-\\>`    сменить cwd neovim на текущую директорию",
    " `<tab>`     цикл по открытым буферам",
    " `<f1>`      эта справка (`q` / `<esc>` — закрыть)",
    "",
    " yazi: `y`/`x`/`p` копировать/вырезать/вставить, `<space>` выделить,",
    "       `a` создать, `r` переименовать, `d` в корзину, `.` скрытые,",
    "       `/` фильтр, `s` поиск (fd/rg), `q` выход",
}

local function show_help()
    local width = 0
    for _, line in ipairs(help_lines) do
        width = math.max(width, vim.fn.strdisplaywidth(line))
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
    vim.bo[buf].modifiable = false

    local height = #help_lines
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        width = width,
        height = height,
        row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
        col = math.max(0, math.floor((vim.o.columns - width) / 2)),
        noautocmd = true,
        zindex = 80, -- поверх окна yazi (70)
    })
    vim.api.nvim_set_option_value("syntax", "help", { buf = buf })
    vim.wo[win].conceallevel = 2
    vim.wo[win].concealcursor = "nc"

    local function close()
        vim.api.nvim_win_close(win, true)
        vim.cmd("startinsert") -- вернуться в терминальный режим yazi
    end
    for _, key in ipairs({ "q", "<esc>", "<f1>" }) do
        vim.keymap.set("n", key, close, { buffer = buf, nowait = true })
    end
end

vim.api.nvim_create_user_command("YaziHelp", show_help, { desc = "Yazi: справка по клавишам" })

require("yazi").setup({
    -- :edit некоторой/директории и `nvim .` открывают yazi вместо netrw
    open_for_directories = true,
    -- НЕ трогаем cwd автоматически: иначе yazi незаметно делает глобальный `:cd`
    -- и пикеры/`:e` начинают работать не от корня проекта. Сменить cwd можно
    -- явно — `<c-\>` внутри yazi.
    change_neovim_cwd_on_close = false,
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_border = "rounded",
    -- поверх snacks-флоатов (styles.float.zindex = 50, терминал = 60)
    yazi_floating_window_zindex = 70,
    -- по умолчанию тут telescope; он стоит (нужен remote-nvim и spell_suggest),
    -- но как основной поиск используем snacks.picker
    integrations = {
        grep_in_directory = "snacks.picker",
        grep_in_selected_files = "snacks.picker",
    },
    keymaps = {
        show_help = false, -- заменено на show_help() выше
    },
    set_keymappings_function = function(buffer)
        vim.keymap.set("t", "<f1>", show_help, { buffer = buffer, desc = "Yazi: справка" })
    end,
})

-- Сама yazi про «корень проекта» ничего не знает — она открывается там, куда её
-- послали. Корень считаем на стороне nvim: сначала репозиторий, потом маркеры
-- модуля, в конце — cwd.
local function project_root()
    local buf_root = vim.fs.root(0, ".git")
        or vim.fs.root(0, { "go.work", "go.mod", "pubspec.yaml", "pyproject.toml", "package.json", "Makefile" })
    return buf_root or vim.uv.cwd()
end

local map = vim.keymap.set

map({ "n", "v" }, "<leader>e", "<cmd>Yazi<cr>", { desc = "Yazi (текущий файл)" })
map("n", "<leader>E", function() require("yazi").yazi(nil, project_root()) end, { desc = "Yazi (корень проекта)" })
map("n", "<leader>ue", "<cmd>Yazi cwd<cr>", { desc = "Yazi (cwd)" })
map("n", "<leader>uy", "<cmd>Yazi toggle<cr>", { desc = "Yazi: возобновить сессию" })
