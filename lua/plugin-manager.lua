-- lazy.nvim: каждый файл в lua/plugins/ возвращает spec-таблицу.
-- Ревизии плагинов фиксирует lazy-lock.json в корне конфига.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Не удалось склонировать lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nНажми любую клавишу для выхода..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("patches").setup()

require("lazy").setup({
    spec = { { import = "plugins" } },
    defaults = {
        -- Всё грузится на старте, как было при vim.pack: конфиги плагинов вешают
        -- глобальные маппинги и автокоманды, и ленивая загрузка требует разметить
        -- для каждого keys/cmd/event. Это можно делать по одному плагину.
        lazy = false,
    },
    install = { colorscheme = { "rose-pine" } },
    -- Ни один плагин тут не тянет зависимости через luarocks, а включённая
    -- поддержка требует luarocks/hererocks и ругается в :checkhealth.
    rocks = { enabled = false },
    change_detection = { notify = false },
})

vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })
