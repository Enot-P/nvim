return {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = function()
        vim.o.foldcolumn = '1'
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = "Раскрыть все" })
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = "Свернуть все" })

        require('ufo').setup({
            provider_selector = function(bufnr, filetype, buftype)
                return {'treesitter', 'indent'}
            end
        })
    end
}