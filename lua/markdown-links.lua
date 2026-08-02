-- Переход по ссылке в markdown: <CR> или двойной клик мышью.
--
-- Штатный gx достаёт цель ссылки (treesitter-запрос markdown_inline кладёт её в
-- metadata), но всегда отдаёт её vim.ui.open -- то есть локальный README.md
-- уедет в xdg-open вместо буфера. Здесь внешние ссылки уходят в vim.ui.open,
-- а относительные пути и якоря открываются внутри nvim.
--
-- render-markdown прячет разметку conceal'ом, но текст в буфере настоящий и
-- позиция курсора реальная -- поиск ссылки по строке от этого не страдает.

local M = {}

-- Метки reference-ссылок: [текст][ref] с определением [ref]: цель ниже в файле.
local function resolve_reference(label)
    label = label:lower()
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        local ref, dest = line:match("^%s*%[([^%]]+)%]:%s*(%S+)")
        if ref and ref:lower() == label then
            return dest
        end
    end
end

-- Ссылка через treesitter -- работает и когда ссылка не влезла в одну строку.
local function link_from_treesitter()
    local ok, node = pcall(vim.treesitter.get_node, { ignore_injections = false })
    if not ok or not node then
        return nil
    end
    while node do
        local t = node:type()
        if t == "inline_link" or t == "image" then
            for child in node:iter_children() do
                if child:type() == "link_destination" then
                    return vim.treesitter.get_node_text(child, 0)
                end
            end
        elseif t == "uri_autolink" then
            return vim.treesitter.get_node_text(node, 0):sub(2, -2)
        end
        node = node:parent()
    end
end

-- Запасной разбор строки. Заодно даёт удобство: если курсор стоит не на самой
-- ссылке, а где-то на строке -- берём первую ссылку этой строки.
local function link_from_line()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    local first, init = nil, 1
    while true do
        local s, e, dest, ref = line:find("%[[^%]]*%]%(([^%)]*)%)", init)
        if not s then
            s, e, ref = line:find("%[[^%]]*%]%[([^%]]*)%]", init)
            if not s then
                break
            end
            dest = resolve_reference(ref)
        end
        if dest then
            if col >= s and col <= e then
                return dest
            end
            first = first or dest
        end
        init = e + 1
    end
    return first
end

-- Заголовок -> якорь: нижний регистр, пробелы в дефисы, пунктуация прочь.
-- lower() не трогает кириллицу, но обе стороны сравнения проходят одну и ту же
-- обработку, так что якоря на русских заголовках всё равно совпадают.
local function slug(s)
    s = s:gsub("^%s+", ""):gsub("%s+$", ""):lower()
    s = s:gsub("[%s]+", "-")
    return (s:gsub("[!-,%.:-@%[-`{-~]", ""))
end

local function jump_to_anchor(anchor)
    local want = slug(anchor)
    for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        local heading = line:match("^#+%s+(.*)$")
        if heading and slug(heading) == want then
            vim.api.nvim_win_set_cursor(0, { i, 0 })
            vim.cmd("normal! zz")
            return true
        end
    end
    vim.notify("Заголовок #" .. anchor .. " не найден", vim.log.levels.WARN)
    return false
end

local function follow(dest)
    -- Внешние схемы (http://, ftp://, mailto:) -- наружу.
    if dest:match("^%a[%w+.%-]*:") and not dest:match("^%a:[/\\]") then
        vim.ui.open(dest)
        return
    end

    local path, anchor = dest:match("^([^#]*)#?(.*)$")
    path = path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)

    vim.cmd("normal! m'") -- чтобы <C-o> вернул назад

    if path ~= "" then
        local target
        if path:match("^[/~]") then
            target = path
        else
            -- Сначала относительно самого файла, потом относительно cwd.
            local from_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h") .. "/" .. path
            local from_cwd = vim.fn.getcwd() .. "/" .. path
            local function exists(p)
                return vim.fn.filereadable(p) == 1 or vim.fn.isdirectory(p) == 1
            end
            target = exists(from_file) and from_file or (exists(from_cwd) and from_cwd or from_file)
        end
        target = vim.fn.fnamemodify(target, ":p")
        if vim.fn.filereadable(target) == 0 and vim.fn.isdirectory(target) == 0 then
            vim.notify("Нет такого файла: " .. target, vim.log.levels.WARN)
        end
        vim.cmd.edit(vim.fn.fnameescape(target))
    end

    if anchor ~= "" then
        jump_to_anchor(anchor)
    end
end

--- Перейти по ссылке под курсором. Возвращает false, если ссылки нет.
function M.follow()
    local dest = link_from_treesitter() or link_from_line()
    if not dest or dest == "" then
        return false
    end
    follow(dest)
    return true
end

function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("markdown_links", { clear = true }),
        pattern = "markdown",
        desc = "Переход по markdown-ссылкам",
        callback = function(args)
            local opts = { buffer = args.buf, silent = true }

            vim.keymap.set("n", "<CR>", function()
                -- Нет ссылки -- отдаём <CR> его обычное значение (строка вниз).
                if not M.follow() then
                    vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
                end
            end, vim.tbl_extend("force", opts, { desc = "Перейти по ссылке" }))

            vim.keymap.set("n", "<2-LeftMouse>", function()
                -- Первый клик двойного клика уже поставил курсор, но при клике по
                -- concealed-тексту позиция бывает смещена -- берём её у мыши.
                local pos = vim.fn.getmousepos()
                if pos.winid == vim.api.nvim_get_current_win() and pos.line > 0 then
                    pcall(vim.api.nvim_win_set_cursor, 0, { pos.line, math.max(pos.column - 1, 0) })
                end
                M.follow()
            end, vim.tbl_extend("force", opts, { desc = "Перейти по ссылке (клик)" }))
        end,
    })
end

return M
