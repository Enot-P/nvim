-- Хелперы именования сессий resession. Живут вне lua/plugins/: lazy читает оттуда
-- только spec-таблицы, а это обычный модуль -- его зовут plugins/resession.lua
-- и дашборд (plugins/dashboard.lua).
local M = {}

-- Имя сессии = имя папки проекта. Один проект = одна сессия: новый снапшот
-- затирает предыдущий, дубликатов в списке не бывает.
function M.name_for_dir(dir)
    local base = vim.fn.fnamemodify(dir or vim.fn.getcwd(), ":p:h:t")
    if base == "" then
        base = "root"
    end
    return (base:gsub("[/:]", "_")) -- чтобы имя сессии совпадало с именем файла
end

-- То, что показываем в дашборде
function M.display_name(name)
    -- старые сессии сохранялись как полный путь с "%" вместо "/"
    if name:match("^%%") then
        local base = vim.fn.fnamemodify((name:gsub("%%", "/")), ":t")
        if base ~= "" then
            return base
        end
    end
    return name
end

-- Когда был сделан снапшот = mtime файла сессии
function M.timestamp(name)
    local file = require("resession.util").get_session_file(name)
    local stat = (vim.uv or vim.loop).fs_stat(file)
    if not stat then
        return ""
    end
    return os.date("%d.%m.%Y %H:%M", stat.mtime.sec)
end

---@return string[] имена сессий, свежие первыми
function M.list(limit)
    local sessions = require("resession").list()
    if limit and #sessions > limit then
        sessions = vim.list_slice(sessions, 1, limit)
    end
    return sessions
end

return M
