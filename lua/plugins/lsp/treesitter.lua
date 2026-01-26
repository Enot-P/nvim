return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            -- 1. Список языков для Flutter-разработки
            local languages = {
                'lua',
                'dart',
                'yaml',
                'json',
                'xml',
                'markdown',
                'markdown_inline',
                'kotlin',
                'java',
                'groovy',
                'make',
                'dockerfile',
                'bash',
                'html',
                'css',
                'javascript',
                'typescript',
                'toml',
                'sql',
                'qmljs',
                'hyprlang'
            }

            -- 2. Установка парсеров (асинхронно)
            require('nvim-treesitter').install(languages)

            -- 3. Включение деревьевиттерных функций для всех языков
            vim.api.nvim_create_autocmd('FileType', {
                pattern = languages,
                callback = function()
                    -- Подсветка синтаксиса (от Neovim)
                    vim.treesitter.start()

                    -- Фолдинг полностью отключен (конфликт с nvim-dbee)
                    -- используем ручной фолдинг вместо этого

                    -- Индентация (от nvim-treesitter)
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end
    }
}
