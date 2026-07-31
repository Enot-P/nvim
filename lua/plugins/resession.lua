vim.pack.add({ "https://github.com/stevearc/resession.nvim" })
vim.pack.add({ "https://github.com/scottmckendry/pick-resession.nvim" })

require("pick-resession").setup({})

local resession = require("resession")

resession.setup({
    load_order = "modification_time", -- свежие сессии идут первыми в списке
    autosave = {
        enabled = true, -- периодически пересохранять уже открытую сессию (страховка от падений)
        interval = 60,
        notify = false,
    },
})

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
    local sessions = resession.list()
    if limit and #sessions > limit then
        sessions = vim.list_slice(sessions, 1, limit)
    end
    return sessions
end

-- Сохранять сессию нет смысла, если открыт только дашборд / пустой буфер
local function has_real_buffers()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            vim.bo[buf].buflisted
            and vim.bo[buf].buftype == ""
            and vim.api.nvim_buf_get_name(buf) ~= ""
        then
            return true
        end
    end
    return false
end

-- Убираем всё, что показывается тем же именем: старые сессии с полным путём
-- и сессии одноимённых папок из других мест.
local function drop_duplicates(keep)
    for _, other in ipairs(resession.list()) do
        if other ~= keep and M.display_name(other) == keep then
            pcall(resession.delete, other, { notify = false })
        end
    end
end

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("resession_save_cwd", { clear = true }),
    desc = "Сохранить сессию текущего каталога при выходе из vim",
    callback = function()
        if not has_real_buffers() then
            return
        end
        local name = M.name_for_dir()
        resession.save(name, { notify = false, attach = false })
        drop_duplicates(name)
    end,
})

-- Resession does NOTHING automagically, so we have to set up some keymaps
vim.keymap.set("n", "<leader>ss", resession.save, { desc = "Session: save" })
vim.keymap.set("n", "<leader>sl", resession.load, { desc = "Session: load" })
vim.keymap.set("n", "<leader>sd", resession.delete, { desc = "Session: delete" })
vim.keymap.set("n", "<leader>sr", function()
    local last = M.list(1)[1]
    if not last then
        vim.notify("Нет сохранённых сессий", vim.log.levels.WARN)
        return
    end
    resession.load(last)
end, { desc = "Session: restore last" })

return M
