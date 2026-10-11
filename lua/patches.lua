-- Локальные патчи плагинов: patches/*.patch, подробности в patches/README.md.
--
-- lazy не обновляет плагин с правками в рабочем дереве ("You have local changes
-- ... Please remove them to update"). Поэтому перед любой операцией lazy патчи
-- снимаются, а когда все операции закончились -- накладываются обратно. Свежая
-- установка плагина тоже операция lazy, так что патч ложится и на новый клон.
--
-- Каталог patches/ в .gitignore: на машине без него патчи молча пропускаются.
local M = {}

-- имя плагина в lazy (как в lazy-lock.json) -> файл в patches/
M.list = {
    ["claudecode.nvim"] = "claudecode-unified-diff-full-width-editable.patch",
    ["flutter-tools.nvim"] = "flutter-tools-document-color-guard.patch",
    ["friendly-snippets"] = "friendly-snippets-make-escaping.patch",
    ["goplements.nvim"] = "goplements-treesitter-has-parser.patch",
}

local patches_dir = vim.fn.stdpath("config") .. "/patches/"

local function git_apply(dir, patch, args)
    local cmd = vim.list_extend({ "git", "-C", dir, "apply" }, args or {})
    table.insert(cmd, patch)
    return vim.system(cmd, { text = true }):wait()
end

---@param fn fun(name: string, dir: string, patch: string)
local function each(fn)
    local plugins = require("lazy.core.config").plugins
    for name, file in pairs(M.list) do
        local plugin = plugins[name]
        local patch = patches_dir .. file
        if plugin and vim.uv.fs_stat(plugin.dir .. "/.git") and vim.uv.fs_stat(patch) then
            fn(name, plugin.dir, patch)
        end
    end
end

function M.apply()
    each(function(name, dir, patch)
        if git_apply(dir, patch, { "--check" }).code == 0 then
            local res = git_apply(dir, patch)
            if res.code ~= 0 then
                vim.notify(("%s: git apply упал\n%s"):format(name, res.stderr), vim.log.levels.ERROR)
            end
        elseif git_apply(dir, patch, { "--reverse", "--check" }).code ~= 0 then
            -- ни наложить, ни снять: апстрим поменял те же строки
            vim.notify(
                ("Патч %s не ложится на %s -- переносить руками, см. patches/README.md"):format(
                    vim.fs.basename(patch),
                    name
                ),
                vim.log.levels.WARN
            )
        end
    end)
end

function M.revert()
    each(function(_, dir, patch)
        if git_apply(dir, patch, { "--reverse", "--check" }).code == 0 then
            git_apply(dir, patch, { "--reverse" })
        end
    end)
end

-- Вызывать до require("lazy").setup(): установка недостающих плагинов идёт прямо
-- внутри setup, и её события иначе пролетят мимо.
function M.setup()
    local group = vim.api.nvim_create_augroup("plugin_patches", { clear = true })
    -- :Lazy sync запускает clean, install и update разом, и install заканчивается
    -- раньше update. Накладываем патчи, только когда закрылась последняя операция.
    local running = 0
    for _, op in ipairs({ "Install", "Update", "Sync", "Restore", "Check", "Clean" }) do
        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "Lazy" .. op .. "Pre",
            callback = function()
                running = running + 1
                M.revert()
            end,
        })
        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "Lazy" .. op,
            callback = function()
                running = math.max(running - 1, 0)
                if running == 0 then
                    M.apply()
                end
            end,
        })
    end
end

return M
