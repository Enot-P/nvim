vim.pack.add({
    "https://github.com/potamides/pantran.nvim",
})

require("pantran").setup({
    default_engine = "yandex",
    engines = {
        yandex = {
            auth_key = os.getenv("YANDEX_API_KEY"),
            default_source = "auto",
            default_target = "ru",
        },
    },
    controls = {
        mappings = {
            edit = {
                n = {
                    ["j"] = "gj",
                    ["k"] = "gk",
                },
                i = {
                    ["<C-y>"] = false,
                    ["<C-a>"] = require("pantran.ui.actions").yank_close_translation,
                },
            },
            select = {
                n = {},
            },
        },
    },
})

-- EN → RU
vim.keymap.set(
    "n",
    "<leader>tt",
    function() return require("pantran").motion_translate() end,
    { noremap = true, silent = true, expr = true, desc = "Translate motion (EN→RU)" }
)
vim.keymap.set(
    "n",
    "<leader>ttt",
    function() return require("pantran").motion_translate() .. "_" end,
    { noremap = true, silent = true, expr = true, desc = "Translate current line (EN→RU)" }
)
vim.keymap.set(
    "x",
    "<leader>tt",
    function() return require("pantran").motion_translate() end,
    { noremap = true, silent = true, expr = true, desc = "Translate selection (EN→RU)" }
)

-- RU → EN
vim.keymap.set(
    "n",
    "<leader>te",
    function() return require("pantran").motion_translate({ source = "ru", target = "en" }) end,
    { noremap = true, silent = true, expr = true, desc = "Translate motion (RU→EN)" }
)
vim.keymap.set(
    "n",
    "<leader>tee",
    function() return require("pantran").motion_translate({ source = "ru", target = "en" }) .. "_" end,
    { noremap = true, silent = true, expr = true, desc = "Translate current line (RU→EN)" }
)
vim.keymap.set(
    "x",
    "<leader>te",
    function() return require("pantran").motion_translate({ source = "ru", target = "en" }) end,
    { noremap = true, silent = true, expr = true, desc = "Translate selection (RU→EN)" }
)

-- which-key группа
require("which-key").add({
    { "<leader>t", group = "Translate" },
})
