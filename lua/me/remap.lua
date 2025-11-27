vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", ":Neotree reveal<CR>", { desc = "Переключить NeoTree" })
vim.keymap.set("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Вертикальное разделение" })
vim.keymap.set("n", "<leader>\\", "<cmd>split<CR>", { desc = "Горизонтальное разделение" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Перейти в левое окно" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Перейти в нижнее окно" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Перейти в верхнее окно" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Перейти в правое окно" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Сохранить" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>", { desc = "Сохранить" })
vim.keymap.set("n", "<leader>Q", ":q!<CR>", { desc = "Выйти без сохранения" })
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Следующий буфер" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Предыдущий буфер" })
vim.keymap.set("n", "<leader>q", ":bdelete<CR>", { desc = "Закрыть текущий буфер" })
for i = 1, 9 do
  vim.keymap.set(
    "n",
    "<leader>" .. i,
    ":BufferLineGoToBuffer " .. i .. "<CR>",
    { desc = "Перейти к буферу " .. i }
  )
end
vim.keymap.set(
  "n",
  "<leader>bx",
  function()
    vim.cmd("wa")
    vim.cmd("BufferLineCloseOthers")
  end,
  { desc = "Закрыть остальные буферы" }
)
-- Window resizing keybindings
vim.keymap.set("n", "<A-j>", ":resize +2<CR>", { desc = "Увеличить высоту окна" })
vim.keymap.set("n", "<A-k>", ":resize -2<CR>", { desc = "Уменьшить высоту окна" })
vim.keymap.set("n", "<A-h>", ":vertical resize +2<CR>", { desc = "Увеличить ширину окна" })
vim.keymap.set("n", "<A-l>", ":vertical resize -2<CR>", { desc = "Уменьшить ширину окна" })
vim.keymap.set("n", "<leader>dj", vim.diagnostic.open_float, { desc = "Показать ошибку под курсором" })
vim.keymap.set("n", "<leader>ge", function()
  require("me.exports").generate_exports()
end, { desc = "Сгенерировать экспортный файл" })
vim.keymap.set(
  "n",
  "<leader>bl",
  function()
    vim.cmd("wa")
    vim.cmd("BufferLineCloseLeft")
  end,
  { desc = "Закрыть вкладки слева" }
)
vim.keymap.set(
  "n",
  "<leader>br",
  function()
    vim.cmd("wa")
    vim.cmd("BufferLineCloseRight")
  end,
  { desc = "Закрыть вкладки справа" }
)

vim.keymap.set("n", "]w", function()
  require("snacks.words").jump(1)
end, { desc = "Следующее слово" })

vim.keymap.set("n", "[w", function()
  require("snacks.words").jump(-1)
end, { desc = "Предыдущее слово" })



-- Настройка клавиатурных сокращений
vim.keymap.set("n", "<leader>tt", "<cmd>TodoTelescope<cr>", { desc = "Search Todos" })
vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo" })
vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous todo" })

vim.api.nvim_set_keymap('n', '<leader>pv', ':PubspecAssistPickVersion<CR>', { noremap = true, silent = true })

vim.keymap.set('i', 'jj', '<Esc>', { noremap = true })

-- Удаление символа без копирования
vim.keymap.set('n', 'x', '"_x', { noremap = true })
vim.keymap.set('v', 'p', '"_dP', { noremap = true })
