vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/sudo-tee/opencode.nvim" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

vim.cmd("packadd plenary.nvim")

require("render-markdown").setup({
    anti_conceal = { enabled = false },
    file_types = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
})

require("opencode").setup({
    preferred_picker = 'snacks',
    preferred_completion = 'blink',
    ui = {
        icons = {
            preset = 'nerdfonts',
        },
    },
})
