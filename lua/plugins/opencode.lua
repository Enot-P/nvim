return {
    "sudo-tee/opencode.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MeanderingProgrammer/render-markdown.nvim",
    },
    config = function()
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
            keymap = {
                editor = {
                    -- <leader>od отдан diffview
                    ['<leader>od'] = false,
                    ['<leader>oD'] = { 'diff_open', desc = 'Open diff view' },
                },
            },
        })
    end,
}
