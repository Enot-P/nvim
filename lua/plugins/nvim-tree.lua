vim.pack.add {
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
}

local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")
  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.map.on_attach.default(bufnr)

  -- удобные клавиши
  vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close dir'))
  vim.keymap.set('n', 'H', api.tree.collapse_all, opts('Collapse all'))
  vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Vsplit'))
end

require("nvim-tree").setup({
  view = { side = "right", width = 30 },
  actions = { open_file = { quit_on_open = true } },
  on_attach = my_on_attach,
  renderer = {
    icons = {
      show = { git = true, file = true },
      glyphs = {
        git = { unstaged = "U", staged = "S", unmerged = "M", renamed = "R", deleted = "D", untracked = "?", ignored = "I" },
      },
    },
  },
})

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
