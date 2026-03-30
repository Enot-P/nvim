vim.pack.add {
    { src = 'https://github.com/saghen/blink.cmp',            version = vim.version.range('^1'), build = 'cargo build --release', },
    { src = 'https://github.com/rafamadriz/friendly-snippets' },
}

require('blink.cmp').setup({
    keymap = {
        preset = 'default',

        ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation' },
        ['<C-e>'] = { 'hide' },
        ['<C-d>'] = { 'scroll_documentation_down' },
        ['<C-u>'] = { 'scroll_documentation_up' },
    },
    appearance = {
        nerd_font_variant = 'mono'
    },
    completion = {
        accept = {
            auto_brackets = { enabled = true },
        },
        documentation = { auto_show = true },
        ghost_text = { enabled = true },

        menu = {
            draw = {
                treesitter = { 'lsp' },
                columns = {
                    { 'kind_icon' },
                    { 'label',      'label_description', gap = 1 },
                    { 'source_name' },
                },
            },
        },
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = {
        implementation = "prefer_rust_with_warning"
    }
})
