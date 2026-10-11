return {
    "potamides/pantran.nvim",
    dependencies = { "folke/which-key.nvim" },
    config = function()
        require("pantran").setup({
            default_engine = "yandex",
            engines = {
                yandex = {
                    default_target = "ru",
                },
            },
            ui = {
                width_percentage = 0.9,
                height_percentage = 0.5,
            },
            controls = {
                mappings = {
                    edit = {
                        n = {
                            ["j"] = "gj",
                            ["k"] = "gk",
                            ["<C-c>"] = require("pantran.ui.actions").close,
                        },
                        i = {
                            ["<C-y>"] = false,
                            ["<C-a>"] = require("pantran.ui.actions").yank_close_translation,
                            ["<C-c>"] = require("pantran.ui.actions").close,
                        },
                    },
                    select = {
                        n = {
                            ["<C-c>"] = require("pantran.ui.actions").close,
                        },
                    },
                },
            },
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "pantran",
            callback = function(ev)
                vim.api.nvim_buf_set_keymap(ev.buf, "n", "<C-c>", "", {
                    callback = function() require("pantran.ui.actions").close() end,
                    noremap = true,
                    silent = true,
                })
                vim.api.nvim_buf_set_keymap(ev.buf, "i", "<C-c>", "", {
                    callback = function() require("pantran.ui.actions").close() end,
                    noremap = true,
                    silent = true,
                })

                vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
                    buffer = ev.buf,
                    callback = function()
                        local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
                        local changed = false
                        for i, line in ipairs(lines) do
                            local clean = line:gsub("\t", " "):gsub("^%s+", ""):gsub("%s+$", "")
                            if clean ~= line then
                                lines[i] = clean
                                changed = true
                            end
                        end
                        if changed then
                            vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, lines)
                        end
                    end,
                })
            end,
        })

        -- Перевод без окна pantran: зовём движки напрямую. Только бесплатные
        -- веб-эндпоинты без ключа, по порядку: если первый не ответил, пробуем
        -- следующий. Модули fallback берём явно, чтобы появившийся ключ API
        -- не переключил на платную версию.
        local free_engines = {}
        for _, name in ipairs({ "yandex", "google" }) do
            local engine = require("pantran.engines.fallback." .. name)
            if pcall(engine.setup) then
                table.insert(free_engines, engine)
            end
        end

        -- Доля кириллицы среди всех букв, начиная с которой текст считается русским
        local CYRILLIC_THRESHOLD = 0.5

        local function is_russian(text)
            local _, cyrillic = text:gsub("[\208-\209][\128-\191]", "")
            local _, latin = text:gsub("%a", "")
            local letters = cyrillic + latin
            return letters > 0 and cyrillic / letters >= CYRILLIC_THRESHOLD
        end

        -- Русский -> английский, всё остальное -> русский.
        -- cb(text, source, target) вызывается только при успехе.
        local function translate(text, cb, opts)
            opts = opts or {}
            local source, target = "auto", "ru"
            if opts.target == "en" or is_russian(text) then
                source, target = "ru", "en"
            end

            vim.api.nvim_echo({ { "Перевожу…", "Comment" } }, false, {})
            require("pantran.async").run(function()
                local ok, result
                for _, engine in ipairs(free_engines) do
                    ok, result = pcall(engine.translate, text, source, target)
                    if ok then
                        break
                    end
                end
                vim.api.nvim_echo({ { "" } }, false, {})
                if not ok then
                    vim.notify("Перевод не удался: " .. tostring(result), vim.log.levels.ERROR)
                    return
                end
                cb(result.text, result.detected or source, target)
            end)
        end

        -- Текущее (или последнее) visual-выделение: текст и позиции.
        -- Выходит из visual, чтобы обновились метки '< и '>.
        local function get_selection()
            local mode = vim.fn.mode()
            if mode == "v" or mode == "V" or mode == "\22" then
                vim.cmd("normal! \27")
            end
            local vmode = vim.fn.visualmode()
            local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
            local lines = vim.fn.getregion(s, e, { type = vmode })
            local pos = vim.fn.getregionpos(s, e, { type = vmode })
            return {
                buf = vim.api.nvim_get_current_buf(),
                mode = vmode,
                text = table.concat(lines, "\n"),
                -- 0-based, конец исключительный -- как ждёт nvim_buf_set_text
                srow = pos[1][1][2] - 1,
                scol = pos[1][1][3] - 1,
                erow = pos[#pos][2][2] - 1,
                ecol = pos[#pos][2][3],
            }
        end

        -- Заменить выделение текстом, если оно не поменялось, пока шёл запрос
        local function replace_selection(sel, text)
            if sel.mode == "\22" then
                vim.notify("Блочное выделение заменить нельзя", vim.log.levels.WARN)
                return false
            end
            if not vim.api.nvim_buf_is_valid(sel.buf) then
                return false
            end
            local last = vim.api.nvim_buf_get_lines(sel.buf, sel.erow, sel.erow + 1, true)[1]
            local ecol = math.min(sel.ecol, #last)
            local current = vim.api.nvim_buf_get_text(sel.buf, sel.srow, sel.scol, sel.erow, ecol, {})
            if table.concat(current, "\n") ~= sel.text then
                vim.notify("Текст изменился, перевод не вставлен", vim.log.levels.WARN)
                return false
            end
            vim.api.nvim_buf_set_text(sel.buf, sel.srow, sel.scol, sel.erow, ecol, vim.split(text, "\n"))
            return true
        end

        -- Окошко с переводом у курсора: q/<Esc> -- закрыть, y -- скопировать,
        -- r -- заменить исходный текст переводом
        local function show_popup(text, source, target, sel)
            local lines = vim.split(text, "\n")
            local width = 20
            for _, l in ipairs(lines) do
                width = math.max(width, vim.fn.strdisplaywidth(l))
            end
            width = math.min(width, math.floor(vim.o.columns * 0.6))
            local height = 0
            for _, l in ipairs(lines) do
                height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(l) / width))
            end

            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].modifiable = false
            vim.bo[buf].bufhidden = "wipe"
            local win = vim.api.nvim_open_win(buf, true, {
                relative = "cursor",
                row = 1,
                col = 0,
                width = width,
                height = math.min(height, math.floor(vim.o.lines * 0.5)),
                style = "minimal",
                border = "rounded",
                title = (" %s → %s "):format(source, target),
                footer = sel and " r заменить · y копировать · q закрыть " or " y копировать · q закрыть ",
                footer_pos = "right",
            })
            vim.wo[win].wrap = true
            vim.wo[win].linebreak = true

            local function close()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
            end
            local function map(lhs, fn) vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true }) end
            map("q", close)
            map("<Esc>", close)
            map("y", function()
                vim.fn.setreg("+", text)
                vim.fn.setreg('"', text)
                close()
                vim.notify("Перевод скопирован")
            end)
            if sel then
                map("r", function()
                    close()
                    replace_selection(sel, text)
                end)
            end
            vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })
        end

        local function translate_selection_popup()
            local sel = get_selection()
            if not sel.text:match("%S") then
                return
            end
            translate(sel.text, function(text, source, target) show_popup(text, source, target, sel) end)
        end

        local function translate_selection_replace()
            local sel = get_selection()
            if not sel.text:match("%S") then
                return
            end
            translate(sel.text, function(text) replace_selection(sel, text) end)
        end

        local function translate_line_popup()
            local line = vim.api.nvim_get_current_line()
            local text = vim.trim(line)
            if text == "" then
                return
            end
            translate(text, function(tr, source, target) show_popup(tr, source, target) end)
        end

        -- Границы комментария на строке row (0-based): {scol, ecol} в байтах,
        -- конец исключительный. Сначала treesitter, потом 'commentstring'.
        local function comment_range(buf, row, line)
            local last = #line:match("^(.-)%s*$")
            -- С инъекциями -- для кода внутри Vue/Markdown, без них -- потому что
            -- сам комментарий часто отдан парсеру `comment` (подсветка TODO),
            -- и у его узлов нет родителя-комментария.
            for _, ignore_injections in ipairs({ false, true }) do
                if last == 0 then
                    break
                end
                local ok, node = pcall(vim.treesitter.get_node, {
                    bufnr = buf,
                    pos = { row, last - 1 },
                    ignore_injections = ignore_injections,
                })
                while ok and node do
                    if node:type():find("comment") then
                        local sr, sc, er, ec = node:range()
                        return sr == row and sc or 0, er == row and ec or #line
                    end
                    node = node:parent()
                end
            end
            local leader = vim.bo[buf].commentstring:match("^%s*(.-)%s*%%s")
            if leader and leader ~= "" then
                local s = line:find(leader, 1, true)
                if s and line:sub(1, s - 1):match("^%s*$") then
                    return s - 1, #line
                end
            end
        end

        -- Перевести русский комментарий на текущей строке на английский прямо в коде
        local function translate_comment()
            local buf = vim.api.nvim_get_current_buf()
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            local line = vim.api.nvim_get_current_line()
            local scol, ecol = comment_range(buf, row, line)
            if not scol then
                vim.notify("На строке нет комментария", vim.log.levels.WARN)
                return
            end
            local comment = line:sub(scol + 1, ecol)
            -- "// " / "-- " / " * " в начале и "*/" / "-->" / "]]" в конце не трогаем
            local prefix = comment:match("^[%p%s]*")
            local suffix = comment:match("%s*%*/$") or comment:match("%s*%-%->$") or comment:match("%s*%]%]$") or ""
            local body = comment:sub(#prefix + 1, #comment - #suffix)
            if not is_russian(body) then
                vim.notify("В комментарии нет русского текста", vim.log.levels.WARN)
                return
            end

            translate(body, function(text)
                if not vim.api.nvim_buf_is_valid(buf) then
                    return
                end
                local now = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
                if now ~= line then
                    vim.notify("Строка изменилась, перевод не вставлен", vim.log.levels.WARN)
                    return
                end
                local bstart = scol + #prefix
                vim.api.nvim_buf_set_text(buf, row, bstart, row, bstart + #body, { text })
                if vim.api.nvim_get_current_buf() == buf and vim.fn.mode():find("^i") then
                    vim.api.nvim_win_set_cursor(0, { row + 1, bstart + #text + #suffix })
                end
            end, { target = "en" })
        end

        vim.keymap.set("x", "<leader>tt", translate_selection_popup, { desc = "Перевести выделение" })
        vim.keymap.set("x", "<leader>tr", translate_selection_replace, { desc = "Заменить выделение переводом" })
        vim.keymap.set("n", "<leader>tt", translate_line_popup, { desc = "Перевести строку" })
        vim.keymap.set("n", "<leader>tc", translate_comment, { desc = "Комментарий RU→EN" })
        vim.keymap.set("i", "<A-t>", translate_comment, { desc = "Комментарий RU→EN" })
        vim.keymap.set("n", "<leader>tT", "<cmd>Pantran<cr>", { desc = "Окно переводчика" })
    end,
}
