vim.pack.add {
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
}


local nts = require("nvim-treesitter")
-- nts.install({ "lua", "go" }) Чтобы каждый раз он не пытался делать установку

vim.api.nvim_create_autocmd('FileType', {
    callback = function() pcall(vim.treesitter.start) end
})

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function()
        nts.update()
    end
})

vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldmethod = 'expr'
vim.o.foldlevel = 99 -- чтобы фолды не закрывались при открытии файла

-- textobjects
vim.pack.add {
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
}

local select = require("nvim-treesitter-textobjects.select")
local move = require("nvim-treesitter-textobjects.move")

-- select (работает в visual и operator-pending режимах)
for lhs, query in pairs({
    ["af"] = "@function.outer",  -- вся функция
    ["if"] = "@function.inner",  -- тело функции
    ["ac"] = "@class.outer",     -- весь класс
    ["ic"] = "@class.inner",     -- тело класса
    ["aa"] = "@parameter.outer", -- аргумент с запятой
    ["ia"] = "@parameter.inner", -- только значение аргумента
}) do
    vim.keymap.set({ "x", "o" }, lhs, function()
        select.select_textobject(query, "textobjects")
    end)
end

-- move
for lhs, query in pairs({
    ["]f"] = "@function.outer",
    ["]c"] = "@class.outer",
}) do
    vim.keymap.set("n", lhs, function()
        move.goto_next_start(query, "textobjects")
    end)
end

for lhs, query in pairs({
    ["[f"] = "@function.outer",
    ["[c"] = "@class.outer",
}) do
    vim.keymap.set("n", lhs, function()
        move.goto_previous_start(query, "textobjects")
    end)
end
