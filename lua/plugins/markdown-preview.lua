return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ft = { "markdown" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function()
      -- Хоткеи для render-markdown
      vim.keymap.set("n", "<leader>mdt", "<cmd>RenderMarkdown toggle<CR>", { desc = "Markdown: Toggle Render" })
      vim.keymap.set("n", "<leader>mde", "<cmd>RenderMarkdown enable<CR>", { desc = "Markdown: Enable Render" })
      vim.keymap.set("n", "<leader>mdd", "<cmd>RenderMarkdown disable<CR>", { desc = "Markdown: Disable Render" })
      vim.keymap.set("n", "<leader>mdp", "<cmd>RenderMarkdown preview<CR>", { desc = "Markdown: Preview (side)" })
      vim.keymap.set("n", "<leader>mdb", "<cmd>RenderMarkdown buf_toggle<CR>", { desc = "Markdown: Toggle for Buffer" })
      vim.keymap.set("n", "<leader>md+", "<cmd>RenderMarkdown expand<CR>", { desc = "Markdown: Expand Margin" })
      vim.keymap.set("n", "<leader>md-", "<cmd>RenderMarkdown contract<CR>", { desc = "Markdown: Contract Margin" })
    end,
  }
}
