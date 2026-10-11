-- Строка подключения к БД проекта из его .env (cwd/.env, парсит vim-dotenv).
--
-- Ключи .env, подходящие под маски, становятся подключениями в DBUI (g:dbs),
-- а самый приоритетный экспортируется в $DATABASE_URL — его берут `:DB` и
-- dadbod-completion. Остальные переменные .env в окружение nvim не попадают.
local M = {}

-- Lua-паттерны имён ключей, по убыванию приоритета
M.patterns = { "^DATABASE_URL$", "^DB_URL$", "DATABASE_URL$", "DB_URL$", "DSN$" }

local local_connections = vim.fn.stdpath("config") .. "/local/database_connections.lua"

local function read_local_dbs()
    local ok, dbs = pcall(dofile, local_connections)
    return ok and type(dbs) == "table" and dbs or {}
end

-- { { key = "DATABASE_URL", url = "postgres://..." }, ... } в порядке приоритета
local function find_urls(env)
    local found, seen = {}, {}
    for _, pattern in ipairs(M.patterns) do
        local keys = {}
        for key, value in pairs(env) do
            -- `://` отсекает не-URL значения вроде go-шного `user:pass@tcp(...)/db`
            if not seen[key] and key:match(pattern) and value:match("^%a[%w+.-]*://") then
                table.insert(keys, key)
            end
        end
        table.sort(keys)
        for _, key in ipairs(keys) do
            seen[key] = true
            table.insert(found, { key = key, url = env[key] })
        end
    end
    return found
end

function M.refresh()
    local dbs = read_local_dbs()
    local cwd = vim.fn.getcwd()
    local env = vim.fn.exists("*DotenvRead") == 1 and vim.fn.DotenvRead(cwd .. "/.env") or {}
    local found = find_urls(env)

    local project = vim.fn.fnamemodify(cwd, ":t")
    for _, item in ipairs(found) do
        local name = #found == 1 and project or project .. "/" .. item.key:lower()
        dbs[name] = item.url
    end
    vim.g.dbs = dbs

    -- nil удаляет переменную: при переходе в проект без .env не остаётся чужой базы
    vim.env.DATABASE_URL = found[1] and found[1].url or nil
end

function M.setup(opts)
    M.patterns = opts and opts.patterns or M.patterns
    vim.g.dbs = read_local_dbs() -- vim-dotenv ещё не загружен, .env прочитаем на VimEnter
    vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
        group = vim.api.nvim_create_augroup("project_db", { clear = true }),
        callback = M.refresh,
    })
end

return M
