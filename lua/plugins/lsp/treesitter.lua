return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            -- Hyprland (hyprlang) не всегда входит в дефолтный набор парсеров nvim-treesitter,
            -- поэтому регистрируем парсер вручную.
            local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
            if ok_parsers and type(parsers.get_parser_configs) == "function" then
                local parser_configs = parsers.get_parser_configs()
                parser_configs.hyprlang = parser_configs.hyprlang
                    or {
                        install_info = {
                            url = "https://github.com/tree-sitter-grammars/tree-sitter-hyprlang",
                            files = { "src/parser.c" },
                            branch = "master",
                        },
                        filetype = "hyprlang",
                    }
            end

            -- 1. Список языков для Flutter-разработки
            local languages = {
                'lua',
                'make',
                'dart',
                'go',
                'gomod',
                'gosum',
                'gowork',
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
                    local ok_start = pcall(vim.treesitter.start)
                    if not ok_start then
                        return
                    end

                    -- Фолдинг полностью отключен (конфликт с nvim-dbee)
                    -- используем ручной фолдинг вместо этого

                    -- Индентация (от nvim-treesitter)
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end
    }
}
