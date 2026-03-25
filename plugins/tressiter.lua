vim.pack.add {
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
}

local nts = require("nvim-treesitter")
nts.install({ "lua", "go" })

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function()
        nts.update()
    end
})

vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldmethod = 'expr'
