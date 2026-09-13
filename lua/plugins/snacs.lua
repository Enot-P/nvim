vim.pack.add({ "https://github.com/folke/snacks.nvim" })

local snacks = require("snacks")

-- mmdc (mermaid-cli) ходит через puppeteer, а тот по умолчанию ищет свой
-- chrome-headless-shell в ~/.cache/puppeteer, которого нет. Отдаём системный chromium,
-- иначе конвертация диаграмм молча падает и картинка не появляется.
if vim.env.PUPPETEER_EXECUTABLE_PATH == nil and vim.fn.executable("chromium") == 1 then
    vim.env.PUPPETEER_EXECUTABLE_PATH = vim.fn.exepath("chromium")
end

snacks.setup({
    bigfile = { enabled = true },
    -- Картинки и mermaid-диаграммы в буфере (kitty graphics protocol).
    -- Блок ```mermaid в markdown конвертируется через mmdc и показывается по курсору,
    -- при этом остаётся обычным текстом — GitHub отрисует его сам.
    image = {
        enabled = true,
        doc = {
            -- Картинка не врезается в текст, а всплывает в отдельном окне, когда
            -- курсор заходит на блок: вёрстка не разъезжается, и диаграмма не висит
            -- на строке буфера — значит render-markdown её ничем не перекрывает.
            inline = false,
            float = true,
            -- Размер в ячейках терминала: чем больше, тем крупнее диаграмма. Для
            -- совсем больших схем этого всё равно мало -- есть <leader>id, см. ниже.
            max_width = 100,
            max_height = 40,
        },
        math = { enabled = false }, -- LaTeX-формулы: нужен tectonic/pdflatex, не ставили
        convert = {
            -- Снимок делается под масштаб терминала (~1.1), из-за чего мелкий текст
            -- в диаграммах мылит. Рендерим вчетверо плотнее и отдаём kitty уменьшать:
            -- downscale читается заметно лучше, чем растягивание мелкого PNG.
            mermaid = function()
                local theme = vim.o.background == "light" and "neutral" or "dark"
                return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "4" }
            end,
        },
    },
    terminal = {
        win = {
            position = "float",
            border = "rounded",
            backdrop = 70,
            width = 0.85,
            height = 0.80,
            zindex = 60,
        },
        stack = true,
        bo = { filetype = "snacks_terminal" },
        keys = {
            q = "hide",
            term_toggle = {
                { "<C-/>", "<C-_>", "<leader>t" },
                function() snacks.terminal() end,
                mode = "t",
                expr = true,
                desc = "Toggle Terminal",
            },
            term_toggle_alt = {
                "<C-_>",
                function() snacks.terminal() end,
                mode = "t",
                expr = true,
                desc = "which_key_ignore",
            },
        },
    },
    styles = {
        float = {
            backdrop = 65,
            border = "rounded",
            zindex = 50,
        },
    },
    dashboard = {
        enabled = false,
        preset = {
            header = [[
⠀⠀⠀⠀⠀⠀⠀⠰⣶⣶⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢰⣿⡟⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣀⣼⣿⣀⣹⣿⡆⠀⢤⡄⢤⣄⢤⡤⠀⢤⣤⣤⣤⣤⢤⣄⠀⢤⣤⡤⣤⣤⣤⢠⡄⠀⣤⢤⡤⢤⡠⣤⠤⣴⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⢹⣿⡇⠉⠉⢿⣿⡄⢸⡇⠀⢹⡏⢿⣠⡟⢹⣿⠤⠄⢸⡿⣷⣼⡇⠀⣿⡇⠀⢸⡇⠀⡇⢸⡇⣎⠀⣿⠶⠌⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡴⠾⠿⠀⠀⠀⠘⠿⠿⠾⠿⠴⠛⠁⠘⠏⠀⠼⠿⠦⠖⠸⠃⠀⠙⠇⠀⠿⠇⠀⠘⠷⠚⠇⠾⠇⠘⠿⠿⠶⠶⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣀⠀⠀⣤⣤⣤⣤⣤⣤⣤⣤⣤⡄⢠⣤⡤⠀⢲⣶⣶⡄⠀⠀⠀⣰⣶⣶⠖⠀⢲⣶⣶⠶⠶⢶⣶⠀⠀⠀⠀
⢀⣀⠀⠀⠀⠀⠀⢀⣸⣿⣉⣀⠀⢟⡉⠉⡉⣿⣿⢉⣉⣙⣛⣘⣿⣇⣀⡀⣿⢿⣿⡄⠀⣼⡿⣿⣿⢠⣤⣬⣭⣭⣤⣤⣤⣬⣤⣤⣀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⢇⣿⠰⠻⣿⣾⡿⠵⣿⣿⠸⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠟⠁
⠀⠀⠀⠀⠀⠀⠀⠉⢹⣿⣍⠁⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⢰⣶⡆⠀⣼⣿⡆⠀⠹⡿⠁⠀⣿⣿⡀⠀⣸⣿⣿⣤⣤⣤⣤⡆⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠉⠀⠀⠀⠀⠀⠴⠟⠛⠂⠀⠀⠀⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠛⠻⠋⠀⠀⠀⠀
            ]],
        },
        sections = {
            { section = "header" },
            { icon = "", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
            { icon = "", title = "Projects", section = "projects", indent = 2, padding = 1 },
            { icon = "", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
            { icon = " ", title = "Sessions", section = "session", indent = 2, padding = 1 },
        },
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = {
        enabled = true,
        sources = {
            -- Дерево каталогов. Штатный пресет explorer -- "sidebar", то есть
            -- вертикальный сплит слева; постоянная панель тут не нужна (файловый
            -- менеджер -- oil), дерево открывается разово и плавающим окном.
            explorer = {
                layout = { preset = "vertical", preview = false },
                -- В сайдбаре окно живёт долго и не закрывается по выбору файла.
                -- Флоат же висел бы поверх только что открытого буфера -- закрываем.
                auto_close = true,
            },
        },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
})

-- ── Keymaps ───────────────────────────────────────────────────────────────────
local map = vim.keymap.set

-- Top Pickers
-- Файловый менеджер — oil (<leader>e), см. plugins/oil.lua;
-- дерево каталогов — snacks.explorer (<leader>fe), настройки в picker.sources выше
map("n", "<leader><space>", function() snacks.picker.smart() end, { desc = "Smart Find Files" })
map("n", "<leader>/", function() snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>nn", function() snacks.picker.notifications() end, { desc = "Notification History" })

-- find

-- Группа для find
vim.keymap.set("n", "<leader>f", "", { desc = "+find" })
map("n", "<leader>fb", function() snacks.picker.buffers() end, { desc = "Buffers" })
map(
    "n",
    "<leader>fc",
    function() snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
    { desc = "Find Config File" }
)
map("n", "<leader>fs", function() Snacks.picker.resession() end, { desc = "Find Sessions" })
map("n", "<leader>fe", function() snacks.explorer() end, { desc = "Дерево каталогов (float)" })
map("n", "<leader>ff", function() snacks.picker.files() end, { desc = "Find Files" })
map("n", "<leader>fg", function() snacks.picker.git_files() end, { desc = "Find Git Files" })
map("n", "<leader>fp", function() snacks.picker.projects() end, { desc = "Projects" })
map("n", "<leader>fr", function() snacks.picker.recent() end, { desc = "Recent" })

-- git

-- Группа для git
vim.keymap.set("n", "<leader>g", "", { desc = "+ git and pretty-comment" })

map("n", "<leader>gb", function() snacks.picker.git_branches() end, { desc = "Git Branches" })
map("n", "<leader>gl", function() snacks.picker.git_log() end, { desc = "Git Log" })
map("n", "<leader>gL", function() snacks.picker.git_log_line() end, { desc = "Git Log Line" })
map("n", "<leader>gs", function() snacks.picker.git_status() end, { desc = "Git Status" })
map("n", "<leader>gS", function() snacks.picker.git_stash() end, { desc = "Git Stash" })
map("n", "<leader>gd", function() snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
map("n", "<leader>gf", function() snacks.picker.git_log_file() end, { desc = "Git Log File" })

-- gh
map("n", "<leader>gi", function() snacks.picker.gh_issue() end, { desc = "GitHub Issues (open)" })
map("n", "<leader>gI", function() snacks.picker.gh_issue({ state = "all" }) end, { desc = "GitHub Issues (all)" })
map("n", "<leader>gp", function() snacks.picker.gh_pr() end, { desc = "GitHub Pull Requests (open)" })
map("n", "<leader>gP", function() snacks.picker.gh_pr({ state = "all" }) end, { desc = "GitHub Pull Requests (all)" })

-- grep
map("n", "<leader>sb", function() snacks.picker.lines() end, { desc = "Buffer Lines" })
map("n", "<leader>sB", function() snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
map("n", "<leader>sg", function() snacks.picker.grep() end, { desc = "Grep" })
map({ "n", "x" }, "<leader>sw", function() snacks.picker.grep_word() end, { desc = "Visual selection or word" })

-- search

-- Группа для search
vim.keymap.set("n", "<leader>s", "", { desc = "+search" })
map("n", '<leader>s"', function() snacks.picker.registers() end, { desc = "Registers" })
map("n", "<leader>s/", function() snacks.picker.search_history() end, { desc = "Search History" })
map("n", "<leader>sa", function() snacks.picker.autocmds() end, { desc = "Autocmds" })
map("n", "<leader>sc", function() snacks.picker.command_history() end, { desc = "Command History" })
map("n", "<leader>sC", function() snacks.picker.commands() end, { desc = "Commands" })
map("n", "<leader>sd", function() snacks.picker.diagnostics() end, { desc = "Diagnostics" })
map("n", "<leader>sD", function() snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
map("n", "<leader>sh", function() snacks.picker.help() end, { desc = "Help Pages" })
map("n", "<leader>sH", function() snacks.picker.highlights() end, { desc = "Highlights" })
map("n", "<leader>si", function() snacks.picker.icons() end, { desc = "Icons" })
map("n", "<leader>sj", function() snacks.picker.jumps() end, { desc = "Jumps" })
map("n", "<leader>sk", function() snacks.picker.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>sl", function() snacks.picker.loclist() end, { desc = "Location List" })
map("n", "<leader>sm", function() snacks.picker.marks() end, { desc = "Marks" })
map("n", "<leader>sM", function() snacks.picker.man() end, { desc = "Man Pages" })
map("n", "<leader>sp", function() snacks.picker.lazy() end, { desc = "Search for Plugin Spec" })
map("n", "<leader>sq", function() snacks.picker.qflist() end, { desc = "Quickfix List" })
map("n", "<leader>sR", function() snacks.picker.resume() end, { desc = "Resume" })
map("n", "<leader>su", function() snacks.picker.undo() end, { desc = "Undo History" })
map("n", "<leader>uC", function() snacks.picker.colorschemes() end, { desc = "Colorschemes" })

-- LSP
map("n", "gd", function() snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
map("n", "gD", function() snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
-- grr (а не голый gr): иначе gr с nowait перехватывал ввод и блокировал
-- нативные grn (rename) / gra (code action) / gri / grt.
map("n", "grr", function() snacks.picker.lsp_references() end, { desc = "References" })
map("n", "gI", function() snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
map("n", "gy", function() snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
map("n", "gai", function() snacks.picker.lsp_incoming_calls() end, { desc = "Calls Incoming" })
map("n", "gao", function() snacks.picker.lsp_outgoing_calls() end, { desc = "Calls Outgoing" })
map("n", "<leader>ss", function() snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
map("n", "<leader>sS", function() snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })

-- Other
map("n", "<leader>z", function() snacks.zen() end, { desc = "Toggle Zen Mode" })
map("n", "<leader>Z", function() snacks.zen.zoom() end, { desc = "Toggle Zoom" })
map("n", "<leader>.", function() snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function() snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
map("n", "<leader>n", function() snacks.notifier.show_history() end, { desc = "Notification History" })
map("n", "<A-q>", function() snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>cR", function() snacks.rename.rename_file() end, { desc = "Rename File" })
map({ "n", "v" }, "<leader>gB", function() snacks.gitbrowse() end, { desc = "Git Browse" })
map("n", "<leader>gg", function() snacks.lazygit() end, { desc = "Lazygit" })
map("n", "<leader>un", function() snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })
map({ "n", "t" }, "<C-/>", function() snacks.terminal() end, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-_>", function() snacks.terminal() end, { desc = "Toggle Terminal" })
map("n", "<C-_>", function() snacks.terminal() end, { desc = "which_key_ignore" })

vim.opt.timeoutlen = 300 -- было 50 — не хватало времени добрать grn/gra/grt и т.п.
-- только normal mode: в терминальном режиме "[[" — это обычный ввод (Lua, шелл),
-- а прыжок по ссылкам в терминальном буфере всё равно бессмыслен
map("n", "]]", function() snacks.words.jump(vim.v.count1) end, { desc = "Next Reference" })
map("n", "[[", function() snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })

vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        _G.dd = function(...) snacks.debug.inspect(...) end
        _G.bt = function() snacks.debug.backtrace() end

        if vim.fn.has("nvim-0.11") == 1 then
            vim._print = function(_, ...) dd(...) end
        else
            vim.print = _G.dd
        end

        snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        snacks.toggle.diagnostics():map("<leader>ud")
        snacks.toggle.line_number():map("<leader>ul")
        snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
        snacks.toggle.treesitter():map("<leader>uT")
        snacks.toggle.inlay_hints():map("<leader>uh")
        snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        snacks.toggle.indent():map("<leader>ug")
        snacks.toggle.dim():map("<leader>uD")
    end,
})


-- ── Просмотр mermaid-диаграмм ─────────────────────────────────────────────────
-- <leader>id -- растр отдельной вкладкой nvim: быстро, не выходя из редактора.
-- <leader>iD -- SVG во внешнем просмотрщике: вектор, зум и панорамирование.
--
-- В normal mode источник -- блок ```mermaid под курсором (markdown-файлы).
-- В visual mode -- просто выделенные строки. Второе нужно для вывода Claude и
-- прочих терминалов: там markdown уже отрисован, ограждений ``` в тексте нет,
-- и найти границы блока автоматически невозможно -- их задаёт выделение.

---@return string? lang, string[]? lines
local function fenced_block_at(buf, row)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local open_at, lang = nil, nil
    for i, line in ipairs(lines) do
        local fence_lang = line:match("^%s*```+(%S*)%s*$")
        if fence_lang then
            if open_at then
                if row >= open_at and row <= i then
                    return lang, vim.list_slice(lines, open_at + 1, i - 1)
                end
                open_at, lang = nil, nil
            else
                open_at, lang = i, fence_lang
            end
        end
    end
end

-- Вывод терминала сдвинут вправо, а mermaid ждёт тип диаграммы в первой строке.
local function dedent(lines)
    local indent = math.huge
    for _, l in ipairs(lines) do
        if l:match("%S") then
            indent = math.min(indent, #l:match("^%s*"))
        end
    end
    if indent == math.huge or indent == 0 then
        return lines
    end
    return vim.tbl_map(function(l) return l:sub(indent + 1) end, lines)
end

local function trim_blank(lines)
    local first, last = 1, #lines
    while first <= last and not lines[first]:match("%S") do
        first = first + 1
    end
    while last >= first and not lines[last]:match("%S") do
        last = last - 1
    end
    return vim.list_slice(lines, first, last)
end

---@param visual boolean источник -- выделение, а не блок под курсором
---@return string[]? body
local function diagram_body(visual)
    if not visual then
        local lang, body = fenced_block_at(0, vim.api.nvim_win_get_cursor(0)[1])
        if not lang then
            snacks.notify.warn("Курсор не внутри блока кода", { title = "Диаграмма" })
        elseif lang ~= "mermaid" then
            snacks.notify.warn("Блок с языком `" .. lang .. "`, а не mermaid", { title = "Диаграмма" })
        elseif not body or #body == 0 then
            snacks.notify.warn("Блок пустой", { title = "Диаграмма" })
        else
            return body
        end
        return
    end

    local from, to = vim.fn.line("v"), vim.fn.line(".")
    if from > to then
        from, to = to, from
    end
    vim.cmd("normal! \27") -- выходим из visual, дальше всё асинхронно
    local body = trim_blank(dedent(vim.api.nvim_buf_get_lines(0, from - 1, to, false)))

    -- Заголовок блока и остатки ограждений, если попали в выделение
    if (body[1] or ""):match("^`*%s*mermaid%s*$") then
        table.remove(body, 1)
    end
    if (body[#body] or ""):match("^```+$") then
        table.remove(body)
    end

    if #body == 0 then
        snacks.notify.warn("В выделении нет текста", { title = "Диаграмма" })
        return
    end
    return body
end

-- Растр силами snacks: он же кеширует результат и умеет рисовать png в буфере.
local function render_tab(body)
    local src = vim.fn.tempname() .. ".mmd"
    vim.fn.writefile(body, src)
    local convert = snacks.image.convert.convert({
        src = src,
        on_done = function(cv)
            vim.schedule(function()
                if cv._err or vim.fn.filereadable(cv.file) == 0 then
                    return snacks.notify.error(
                        "Не удалось отрисовать:\n" .. tostring(cv._err),
                        { title = "Диаграмма" }
                    )
                end
                -- snacks перехватывает открытие файлов-картинок и рисует их в буфере
                vim.cmd("tabedit " .. vim.fn.fnameescape(cv.file))
                vim.keymap.set("n", "q", "<cmd>tabclose<cr>", { buffer = 0, desc = "Закрыть диаграмму" })
            end)
        end,
    })
    convert:run()
end

-- Вектор напрямую через mmdc: snacks умеет только растр.
local function render_external(body)
    local src = vim.fn.tempname() .. ".mmd"
    vim.fn.writefile(body, src)
    local out = vim.fn.tempname() .. ".svg"

    -- Фон задаём явно: с transparent светлый текст тёмной темы теряется на белой
    -- странице браузера.
    local dark = vim.o.background ~= "light"
    local theme = dark and "dark" or "default"
    local bg = dark and "#1e1e2e" or "white"

    snacks.notify.info("Рендерю диаграмму…", { title = "Диаграмма" })
    vim.system({ "mmdc", "-i", src, "-o", out, "-b", bg, "-t", theme }, { text = true }, function(res)
        vim.schedule(function()
            if res.code ~= 0 or vim.fn.filereadable(out) == 0 then
                return snacks.notify.error(
                    "mmdc вернул " .. res.code .. ":\n" .. (res.stderr or ""),
                    { title = "Диаграмма" }
                )
            end
            vim.ui.open(out)
        end)
    end)
end

local function diagram(visual, render)
    return function()
        local body = diagram_body(visual)
        if body then
            render(body)
        end
    end
end

map("n", "<leader>id", diagram(false, render_tab), { desc = "Диаграмма под курсором -- вкладкой" })
map("x", "<leader>id", diagram(true, render_tab), { desc = "Диаграмма из выделения -- вкладкой" })
map("n", "<leader>iD", diagram(false, render_external), { desc = "Диаграмма под курсором -- просмотрщик" })
map("x", "<leader>iD", diagram(true, render_external), { desc = "Диаграмма из выделения -- просмотрщик" })
